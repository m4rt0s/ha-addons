# Factorio Server

Runs a dedicated Factorio server from the
[factoriotools/factorio](https://github.com/factoriotools/factorio-docker) image.
The app version follows the Factorio version it ships.

## Where the data lives

Saves, mods and configuration are in the app's **config folder**, not inside the
container, so they survive updates and are included in Home Assistant backups:

- Samba share **addon_configs** → `<id>_factorio/` (or the File editor / SSH
  at `/addon_configs/<id>_factorio/`).
- Inside it: `saves/`, `mods/`, `config/server-settings.json`,
  `config/map-gen-settings.json`, `config/map-settings.json`.

Edit `config/server-settings.json` for the server name, password, max players,
admins, etc., then restart the app.

## Moving an existing server (for example from a NAS)

1. Stop the old server.
2. Copy the whole old data folder (`saves/`, `mods/`, `config/`) into the app's
   config folder. Start the app once first so the folder exists.
3. Start the app. With *Load latest save* on it resumes the newest save.

The app runs as user/group `1000:1000`; ownership is fixed on every start.

## Options

- **Load latest save** — default on.
- **Generate new save** / **Save name** — create a map when it does not exist.
- **Preset** — map preset for new maps (default `default`).
- **Space Age DLC** — default off.
- **Update mods on start** — default off; needs factorio.com credentials in
  `server-settings.json`.
- **Time zone** — default `Europe/Madrid`.

## Network

Players connect to **`<your-server-address>:34197`** (UDP). Forward UDP `34197`
on your router for internet play. RCON (`27015/tcp`) is not exposed.

## Resource limits

Home Assistant apps cannot set memory/CPU limits like Docker Compose does. A
base-game server is light, but large factories can use more than 2 GB.
