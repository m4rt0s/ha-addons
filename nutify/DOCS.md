# Nutify

[Nutify](https://github.com/DartSteven/Nutify) is a web UPS monitoring system
built on [Network UPS Tools](https://networkupstools.org): live status,
history, alerts, scheduled reports and charts. This app packages the upstream
Docker image for Home Assistant.

## Connect it to your UPS

This app does **not** need USB access. If your UPS is already served by the
**Network UPS Tools** app (or any NUT server), add it as a *remote* UPS:

1. Open the web interface (**Open Web UI**, port `5050`) and create the first
   user.
2. In the setup wizard choose a **remote NUT server**.
3. Host: `a0d7b954-nut` when using the Network UPS Tools app, otherwise the
   server's address. Port: `3493`. UPS name: the one in that app's
   configuration (for example `ups0`).
4. User and password: a user defined in that app (`upsmon` role is enough for
   monitoring). Credentials are stored by Nutify, never in this repository.

Do not point this app at a USB UPS that another app already uses: a USB device
can only be claimed by one driver. Port `3493` is deliberately **not** exposed
here so it cannot clash with the NUT app.

## Options

- **Time zone** — default `Europe/Madrid`.
- **Log level** — default `INFO`.
- **Secret key** — empty by default; a key is generated on first start and kept
  in the app's data.
- **Allowed origins** — empty by default (same origin only).

## Data

Database, logs and the generated NUT configuration live in the app's `/data`
folder and survive updates. They are included in Home Assistant backups.

## Notes

- Not exposed through Ingress: open the web UI on port `5050`.
- Upstream release `0.3.0` is not backward compatible with older Nutify data.

---

## En español

Nutify monitoriza el SAI desde una interfaz web. Conéctalo como **servidor NUT
remoto** al app *Network UPS Tools* (host `a0d7b954-nut`, puerto `3493`). No
necesita USB, y el puerto `3493` no se publica para no chocar con el app NUT.
