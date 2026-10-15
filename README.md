# PyPowerwall Server (Home Assistant app)

[jasonacox/pypowerwall-server](https://github.com/jasonacox/pypowerwall-server)
packaged as a Home Assistant app (add-on). It talks to the Powerwall gateway
over the host's WiFi link (`192.168.91.1`) and exposes the console and API on
port 8677, with optional MQTT and Home Assistant auto-discovery.

## Install

Settings → Apps → App store → ⋮ → Repositories → add
`https://github.com/m4rt0s/ha-pypowerwall-server`, then install
"PyPowerwall Server".

## Options

All options are shown in the app's **Configuration** tab with a Spanish/English
name and a description that states the app's **default value**. Optional
settings are pre-filled with that default, so leaving them untouched keeps the
upstream behaviour.

| Group | Options |
|---|---|
| Connection | `pw_host`, `pw_gw_pwd`, `timezone`, `gateway_name` |
| Performance | `cache_expire`, `timeout`, `cache_ttl`, `graceful_degradation`, `tedapi_recovery`, `tedapi_probe_interval`, `health_check`, `fail_fast`, `suppress_network_errors` |
| Look | `style`, `neg_solar` |
| Time series | `timeseries_retention`, `timeseries_daily_retention`, `timeseries_signal_retention`, `timeseries_signal_interval` |
| MQTT | `mqtt_host`, `mqtt_port`, `mqtt_username`, `mqtt_password`, `mqtt_ha_discovery`, `mqtt_topic_prefix`, `mqtt_ha_prefix`, `mqtt_retain`, `mqtt_qos`, `mqtt_keepalive`, `mqtt_client_id`, `mqtt_tls` |
| Control | `mqtt_controls`, `control_secret` (read-only unless set; use at your own risk) |
| Advanced | `cors_origins` (comma-separated; CORS is **disabled** by default), `rate_limit_enabled`, `rate_limit_max_requests`, `rate_limit_window_seconds`, `rate_limit_max_buckets`, `debug` |

Each option maps to the matching `PW_*` / `MQTT_*` environment variable of
[pypowerwall-server](https://github.com/jasonacox/pypowerwall-server).
MQTT-specific options are only applied when `mqtt_host` is set.
