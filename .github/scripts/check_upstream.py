#!/usr/bin/env python3
"""Open a pull request when an app's upstream project has a newer release.

For every app in .github/upstream.json: read the version in use, ask GitHub for the
upstream release, check the Docker image tags exist, and (if newer) bump the base image,
the app `version` and the CHANGELOG on a new branch, then open a PR.
Only needs `gh` and git on PATH (GH_TOKEN in the environment).
"""
import argparse, json, os, re, subprocess, sys, urllib.request, urllib.error

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))


def sh(*args, check=True, cwd=None):
    r = subprocess.run(args, capture_output=True, text=True, cwd=cwd or ROOT)
    if check and r.returncode != 0:
        raise RuntimeError(f"{' '.join(args)}\n{r.stderr.strip()}")
    return r.stdout.strip()


def ver(s):
    return tuple(int(x) for x in s.split("."))


def latest_release(repo, prereleases):
    rel = json.loads(sh("gh", "api", f"repos/{repo}/releases?per_page=30"))
    for r in rel:
        if r.get("draft"):
            continue
        if r.get("prerelease") and not prereleases:
            continue
        m = re.fullmatch(r"v?(\d+\.\d+\.\d+)", r["tag_name"])
        if m:
            return m.group(1), r["html_url"], bool(r.get("prerelease"))
    return None


def tag_exists(image, tag):
    url = f"https://hub.docker.com/v2/repositories/{image}/tags/{tag}"
    try:
        with urllib.request.urlopen(url, timeout=30) as r:
            return r.status == 200
    except urllib.error.HTTPError:
        return False


def current_version(app):
    b = app["bump"][0]
    path = os.path.join(ROOT, app["dir"], b["file"])
    m = re.search(b["regex"], open(path).read())
    return m.group(2) if m else None


def next_addon_version(current, upstream):
    c, u = ver(current), ver(upstream)
    if u > c:
        return upstream
    return "%d.%d.%d" % (c[0], c[1], c[2] + 1)


def edit(path, fn):
    s = open(path).read()
    n = fn(s)
    if n == s:
        raise RuntimeError(f"no change in {path}")
    open(path, "w").write(n)


def changelog_entry(app, addon_ver, up_ver, url, prerelease):
    if app["changelog_lang"] == "es":
        pre = " (versión preliminar)" if prerelease else ""
        return (f"## {addon_ver}\n\n- Actualiza {app['name']} a la versión **{up_ver}** de upstream{pre}. "
                f"Notas de la versión: {url}\n\n")
    pre = " (pre-release)" if prerelease else ""
    return (f"## {addon_ver}\n\n- Update to upstream **{up_ver}**{pre}. Release notes: {url}\n\n")


def process(app, base, dry, force=False):
    cur = current_version(app)
    if not cur:
        print(f"[{app['name']}] cannot read the current version"); return
    found = latest_release(app["upstream"], app["include_prereleases"])
    if not found:
        print(f"[{app['name']}] no upstream release found"); return
    new, url, pre = found
    if ver(new) <= ver(cur):
        print(f"[{app['name']}] up to date ({cur})"); return
    missing = [t.format(v=new) for t in app["tags"] if not tag_exists(app["image"], t.format(v=new))]
    if missing:
        print(f"[{app['name']}] {new} released but image tags are missing: {missing}; waiting"); return
    branch = f"upstream/{app['name']}-{new}"
    if not force and json.loads(sh("gh", "pr", "list", "--head", branch, "--state", "all", "--json", "number")):
        print(f"[{app['name']}] a PR for {new} already exists"); return
    cfg_path = os.path.join(ROOT, app["dir"], "config.yaml")
    addon_cur = re.search(r'^version:\s*"?([\d.]+)"?', open(cfg_path).read(), re.M).group(1)
    addon_new = next_addon_version(addon_cur, new)
    print(f"[{app['name']}] {cur} -> {new}; app version {addon_cur} -> {addon_new}"
          + (" (pre-release)" if pre else ""))
    if dry:
        return
    sh("git", "checkout", "-q", "-B", branch)
    for b in app["bump"]:
        edit(os.path.join(ROOT, app["dir"], b["file"]),
             lambda s, b=b: re.sub(b["regex"], lambda m: m.group(1) + new, s))
    edit(cfg_path, lambda s: re.sub(r'^(version:\s*)"?[\d.]+"?', lambda m: f'{m.group(1)}"{addon_new}"', s, count=1, flags=re.M))
    cl = os.path.join(ROOT, app["dir"], "CHANGELOG.md")
    entry = changelog_entry(app, addon_new, new, url, pre)
    edit(cl, lambda s: re.sub(r"(# [^\n]*\n\n)", lambda m: m.group(1) + entry, s, count=1))
    sh("git", "add", "-A")
    sh("git", "commit", "-q", "-m", f"{app['name']}: update to upstream {new}")
    sh("git", "push", "-q", "--force", "origin", branch)
    body = (f"Upstream **{app['upstream']}** released [{new}]({url})"
            + (" (a pre-release)" if pre else "") + ".\n\n"
            f"- Base image: `{cur}` -> `{new}`\n- App version: `{addon_cur}` -> `{addon_new}`\n\n"
            "Before merging:\n" + "\n".join(f"- [ ] {x}" for x in app["review"]) + "\n")
    out = sh("gh", "pr", "create", "--base", base, "--head", branch,
             "--title", f"{app['name']}: update to upstream {new}", "--body", body)
    print(f"[{app['name']}] PR: {out}")
    sh("git", "checkout", "-q", base)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="main")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--force", action="store_true", help="ignore existing/closed PRs for the same version")
    ap.add_argument("--only")
    a = ap.parse_args()
    cfg = json.load(open(os.path.join(ROOT, ".github", "upstream.json")))
    fail = 0
    for app in cfg["apps"]:
        if a.only and a.only != app["name"]:
            continue
        try:
            process(app, a.base, a.dry_run, a.force)
        except Exception as e:  # keep going with the other apps
            fail += 1
            print(f"[{app['name']}] ERROR: {e}", file=sys.stderr)
            if not a.dry_run:
                sh("git", "checkout", "-q", "-f", a.base, check=False)
    sys.exit(1 if fail else 0)


main()
