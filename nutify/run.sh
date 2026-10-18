#!/bin/bash
set -e

get() {
  python3 - "$1" <<'PY'
import json, sys
v = json.load(open("/data/options.json")).get(sys.argv[1], "")
print(str(v).lower() if isinstance(v, bool) else ("" if v is None else v))
PY
}

# Persist Nutify state under /data (survives updates and restarts).
for d in instance logs ssl etc-nut; do mkdir -p "/data/$d"; done
link() { rm -rf "$2"; mkdir -p "$(dirname "$2")"; ln -sfn "$1" "$2"; }
link /data/instance /app/nutify/instance
link /data/logs     /app/nutify/logs
link /data/ssl      /app/ssl
link /data/etc-nut  /etc/nut

# The app runs as "nut"; the image entrypoint cannot reach through the symlinks.
chown -R nut:nut /data/instance /data/logs /data/ssl /data/etc-nut
chmod 750 /data/etc-nut

# Session/credential key: use the option if set, otherwise generate once and keep it.
SECRET_KEY="$(get secret_key)"
if [ -z "$SECRET_KEY" ]; then
  [ -s /data/secret_key ] || head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' > /data/secret_key
  SECRET_KEY="$(cat /data/secret_key)"
fi
export SECRET_KEY

export TZ="$(get timezone)"
export LOG_LEVEL="$(get log_level)"
export SOCKETIO_ALLOWED_ORIGINS="$(get socketio_allowed_origins)"
export NUTIFY_WEB_USER=nut NUT_SERVICE_USER=nut
export UDEV=0 SKIP_PERMCHECK=true LOG=true LOG_WERKZEUG=true ENABLE_LOG_STARTUP=Y SSL_ENABLED=false

exec /usr/local/bin/generate-settings.sh /usr/local/bin/docker-entrypoint /usr/local/bin/start-services.sh
