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

- `pw_host`: gateway IP (default `192.168.91.1`)
- `pw_gw_pwd`: gateway password
- `timezone`
- `mqtt_*`: broker settings (leave `mqtt_host` empty to disable MQTT)
