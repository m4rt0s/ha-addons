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

# Single-gateway mode hardcodes the name "Default Gateway"; PW_GATEWAYS lets us set it.
# The id stays "default" so MQTT topics, entity ids and legacy endpoints do not change.
GW_NAME="$(get gateway_name)"
if [ -n "$GW_NAME" ]; then
  PW_GATEWAYS="$(python3 - "$GW_NAME" <<'PY'
import json, os, sys
print(json.dumps([{"id": "default", "name": sys.argv[1], "host": os.environ["PW_HOST"],
                   "gw_pwd": os.environ["PW_GW_PWD"], "timezone": os.environ["PW_TIMEZONE"]}]))
PY
)"
  export PW_GATEWAYS
fi

MQTT_HOST="$(get mqtt_host)"
if [ -n "$MQTT_HOST" ]; then
  export MQTT_HOST
  export MQTT_PORT="$(get mqtt_port)"
  export MQTT_USERNAME="$(get mqtt_username)"
  export MQTT_PASSWORD="$(get mqtt_password)"
  export MQTT_HA_DISCOVERY="$(get mqtt_ha_discovery)"
fi

# Opciones extra: solo se exportan las que tienen valor; vacio = se usa el valor por defecto de la app
eval "$(python3 - <<'PY'
import json, shlex
opts = json.load(open("/data/options.json"))
mqtt_on = bool(str(opts.get("mqtt_host") or "").strip())
MAP = {'cache_expire': ['PW_CACHE_EXPIRE', 'int(1,300)?', False], 'timeout': ['PW_TIMEOUT', 'int(1,120)?', False], 'cache_ttl': ['PW_CACHE_TTL', 'int(1,3600)?', False], 'graceful_degradation': ['PW_GRACEFUL_DEGRADATION', 'bool?', False], 'tedapi_recovery': ['PW_TEDAPI_RECOVERY', 'bool?', False], 'tedapi_probe_interval': ['PW_TEDAPI_PROBE_INTERVAL', 'int(5,3600)?', False], 'style': ['PW_STYLE', 'list(clear|black|white|grafana|grafana-dark)?', False], 'neg_solar': ['PW_NEG_SOLAR', 'bool?', False], 'timeseries_retention': ['PW_TIMESERIES_RETENTION', 'str?', False], 'timeseries_daily_retention': ['PW_TIMESERIES_DAILY_RETENTION', 'str?', False], 'timeseries_signal_retention': ['PW_TIMESERIES_SIGNAL_RETENTION', 'str?', False], 'timeseries_signal_interval': ['PW_TIMESERIES_SIGNAL_INTERVAL', 'str?', False], 'mqtt_topic_prefix': ['MQTT_TOPIC_PREFIX', 'str?', True], 'mqtt_ha_prefix': ['MQTT_HA_PREFIX', 'str?', True], 'mqtt_retain': ['MQTT_RETAIN', 'bool?', True], 'mqtt_qos': ['MQTT_QOS', 'int(0,2)?', True], 'mqtt_keepalive': ['MQTT_KEEPALIVE', 'int(10,600)?', True], 'mqtt_client_id': ['MQTT_CLIENT_ID', 'str?', True], 'mqtt_tls': ['MQTT_TLS', 'bool?', True], 'mqtt_controls': ['MQTT_CONTROLS', 'int(0,31)?', True], 'control_secret': ['PW_CONTROL_SECRET', 'password?', False], 'rate_limit_enabled': ['PW_RATE_LIMIT_ENABLED', 'bool?', False], 'debug': ['PW_DEBUG', 'bool?', False]}
for key, (env, sch, only_mqtt) in MAP.items():
    v = opts.get(key)
    if v is None or v == "":
        continue
    if only_mqtt and not mqtt_on:
        continue
    if isinstance(v, bool):
        v = "true" if v else "false"
    print(f"export {env}={shlex.quote(str(v))}")
PY
)"
if [ "${MQTT_CONTROLS:-0}" != "0" ] && [ -z "${PW_CONTROL_SECRET:-}" ]; then
  echo "AVISO: mqtt_controls activo pero falta control_secret; los controles no funcionaran"
fi

# Ingress: tell the server the path HA serves it under (empty = serve at root)
if [ -n "${SUPERVISOR_TOKEN:-}" ]; then
  ENTRY="$(curl -s -m 10 -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/addons/self/info \
    | python3 -c '
import sys, json, re
d = json.load(sys.stdin).get("data", {})
for k in ("ingress_url", "ingress_entry"):
    m = re.search(r"/api/hassio_ingress/[A-Za-z0-9_-]+", str(d.get(k) or ""))
    if m:
        print(m.group(0))
        break
' 2>/dev/null || true)"
  if [ -n "$ENTRY" ]; then
    export PROXY_BASE_URL="$ENTRY"
  fi
fi

echo "PyPowerwall Server: gateway ${PW_HOST}, MQTT ${MQTT_HOST:-disabled}, base ${PROXY_BASE_URL:-/}"
cd /app
exec uvicorn app.main:app --host 0.0.0.0 --port 8675
