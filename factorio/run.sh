#!/bin/bash
set -e

# Read an option from the Supervisor-provided file (booleans stay "true"/"false").
opt() { jq -r --arg k "$1" '.[$k] | if . == null then "" else tostring end' /data/options.json; }

# Everything Factorio keeps (saves, mods, config, server-settings.json) lives in the
# app's config folder, which is editable from Samba / the File editor and backed up.
PUID=1000; PGID=1000
chown -R "$PUID:$PGID" /config
rm -rf /factorio
ln -sfn /config /factorio

export TZ="$(opt timezone)"
export LOAD_LATEST_SAVE="$(opt load_latest_save)"
export GENERATE_NEW_SAVE="$(opt generate_new_save)"
export SAVE_NAME="$(opt save_name)"
export PRESET="$(opt preset)"
export DLC_SPACE_AGE="$(opt dlc_space_age)"
export UPDATE_MODS_ON_START="$(opt update_mods_on_start)"
export PUID PGID

exec /docker-entrypoint.sh
