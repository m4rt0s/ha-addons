# Changelog

## 0.4.0

- Home Assistant Ingress: Nutify now opens from the sidebar (an internal nginx rewrites absolute paths, redirects and cookies to the ingress prefix).
- Port 5050 stays available for direct LAN access.

## 0.3.1

- Fix: give the `nut` user ownership of the persistent folders (logs were not writable and the web app failed to start).

## 0.3.0

- First release of the Home Assistant app, based on Nutify upstream 0.3.0.
- Remote NUT server mode (no USB access), persistent data in `/data`, automatic secret key.
