#!/bin/bash
set -e
OPT=/data/options.json
get() {
  python3 - "$1" <<'PY'
import json, sys
v = json.load(open("/data/options.json")).get(sys.argv[1], "")
print(str(v).lower() if isinstance(v, bool) else ("" if v is None else v))
PY
}

export PW_HOST="$(get pw_host)"
export PW_GW_PWD="$(get pw_gw_pwd)"
export PW_TIMEZONE="$(get timezone)"

MQTT_HOST="$(get mqtt_host)"
if [ -n "$MQTT_HOST" ]; then
  export MQTT_HOST
  export MQTT_PORT="$(get mqtt_port)"
  export MQTT_USERNAME="$(get mqtt_username)"
  export MQTT_PASSWORD="$(get mqtt_password)"
  export MQTT_HA_DISCOVERY="$(get mqtt_ha_discovery)"
fi

echo "PyPowerwall Server: gateway ${PW_HOST}, MQTT ${MQTT_HOST:-disabled}"
cd /app
exec uvicorn app.main:app --host 0.0.0.0 --port 8675
