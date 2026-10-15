# PyPowerwall Server

**ES** · Datos en tiempo real de tu **Tesla Powerwall** en Home Assistant, leídos en **local** (sin nube de Tesla):
potencias, batería, red, solar, temperaturas, historial diario y consola web integrada en la barra lateral.
Publica por **MQTT** con autodescubrimiento y crea las entidades solo.

- Consola web en el panel *Powerwall* (Ingress) o en el puerto 8677
- 39 opciones configurables desde la interfaz, con su valor por defecto
- Solo lectura por defecto; controles opcionales
- Basado en [pypowerwall-server](https://github.com/jasonacox/pypowerwall-server)

Necesitas que el host de Home Assistant llegue al gateway (`192.168.91.1`) y su contraseña. Lee la pestaña **Documentación**.

**EN** · Real-time local data from your **Tesla Powerwall** in Home Assistant (no Tesla cloud): power flows, battery,
grid, solar, temperatures, daily history, and a built-in console in the sidebar. Publishes via **MQTT** with auto-discovery.
Read-only by default. See the **Documentation** tab. Not affiliated with Tesla.
