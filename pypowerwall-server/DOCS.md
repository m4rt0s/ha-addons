# PyPowerwall Server

Lleva a Home Assistant la información en tiempo real de tu **Tesla Powerwall**, leyéndola **en local**,
sin depender de la nube de Tesla. Es el proyecto [pypowerwall-server](https://github.com/jasonacox/pypowerwall-server)
de Jason Cox empaquetado como app de Home Assistant. No está afiliado ni respaldado por Tesla.

## Cómo funciona

```
 Powerwall / Gateway ──WiFi──► Host de Home Assistant ──► App PyPowerwall Server
   (192.168.91.1)                  (tu servidor)               │
                                                               ├─► Consola web (panel "Powerwall" en la barra lateral)
                                                               ├─► API REST (puerto 8677)
                                                               └─► MQTT ─► Home Assistant (entidades por autodescubrimiento)
```

1. La app habla con el gateway por la **API local TEDAPI** usando la contraseña de la pegatina del gateway.
2. Cada pocos segundos (`cache_expire`) lee potencias, batería, red, solar, temperaturas y ventiladores.
3. Los muestra en su consola web y, si configuras un broker MQTT, **publica los datos y crea las entidades** en Home Assistant.
4. Guarda un historial propio (energía diaria, temperaturas) en `/data`, que se conserva al actualizar.

## Requisitos

- El **host de Home Assistant debe llegar a `192.168.91.1`**: lo normal es unirlo al WiFi del gateway (`TeslaPW_XXXXX`).
  La app no se conecta por sí sola al WiFi; usa la red del host.
- La **contraseña del gateway** (pegatina del Backup Gateway o de la app de Tesla).
- Para tener entidades: el add-on **Mosquitto** (o cualquier broker MQTT) y la integración MQTT de Home Assistant.

## Primeros pasos

1. Abre la pestaña **Configuración** e introduce `pw_gw_pwd` (la contraseña del gateway).
2. Revisa `timezone` y, **antes de activar MQTT**, `gateway_name` (da nombre al dispositivo y a las entidades; después Home Assistant no las renombra).
3. Para tener entidades, pon en `mqtt_host` el broker (`core-mosquitto` si usas el add-on Mosquitto) y su usuario y contraseña.
4. Pulsa **Guardar** e **Iniciar**. Activa *Iniciar en el arranque* y *Watchdog*.
5. Abre el panel **Powerwall** de la barra lateral. Si no lo ves, actívalo con *Mostrar en la barra lateral*.

## Acceso

| Cómo | Dónde |
|---|---|
| Panel de la barra lateral (Ingress) | **Powerwall** → consola |
| Botón de la app | **Abrir interfaz web** |
| Directo en tu red | `http://IP-de-HA:8677/console` |
| Documentación de la API | `http://IP-de-HA:8677/docs` |
| Estado | `http://IP-de-HA:8677/health` |

> No expongas el puerto 8677 a Internet. Si lo haces, activa límite de peticiones y no uses controles.

## Entidades en Home Assistant

Con MQTT activo aparece un dispositivo con el nombre de `gateway_name` y sensores de: potencias (solar, casa, red, batería),
porcentaje y energía de la batería, acumulados de energía (Wh), strings solares, temperaturas, ventiladores, modo de operación,
estado de la red, firmware y más. Los acumulados llegan en Wh: si prefieres kWh/MWh, cambia la unidad en los ajustes de la entidad.

## Opciones

Todas se editan en **Configuración**. Las opcionales vienen **rellenas con el valor por defecto de la app**; si no las cambias,
la app se comporta como siempre. Las específicas de MQTT solo se aplican si `mqtt_host` tiene valor.

### Conexión

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `pw_host` | IP del gateway | texto | `192.168.91.1` | Dirección del gateway de la Powerwall. Por defecto: 192.168.91.1. |
| `pw_gw_pwd` | Contraseña del gateway | contraseña | vacío | Contraseña del gateway (la de la pegatina). Obligatoria. |
| `timezone` | Zona horaria | texto | `Europe/Madrid` | Zona horaria de la instalación. Por defecto de la app: America/Los_Angeles; aquí: Europe/Madrid. |
| `gateway_name` | Nombre del dispositivo | texto | `Powerwall` | Nombre que se verá en Home Assistant y en la consola. Por defecto de la app: Default Gateway; aquí: Powerwall. |

### Rendimiento

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `cache_expire` | Intervalo de consulta (s) | entero 1–300 | `5` | Segundos entre consultas al gateway. Menos = datos más frescos y más carga. Por defecto: 5. |
| `timeout` | Tiempo de espera (s) | entero 1–120 | `10` | Tiempo máximo de espera de cada petición al gateway. Por defecto: 10. |
| `cache_ttl` | Antigüedad máx. de la caché (s) | entero 1–3.600 | `30` | Si el gateway no responde se sirven datos en caché de hasta esta antigüedad. Por defecto: 30. |
| `graceful_degradation` | Usar caché si el gateway falla | sí / no | sí | Sirve los últimos datos conocidos cuando el gateway no responde. Por defecto: sí. |
| `tedapi_recovery` | Recuperación automática TEDAPI | sí / no | sí | Reintenta solo la conexión TEDAPI si cae al modo solo solar. Por defecto: sí. |
| `tedapi_probe_interval` | Sondeo TEDAPI (s) | entero 5–3.600 | `30` | Segundos entre comprobaciones de salud de TEDAPI. Por defecto: 30. |
| `health_check` | Monitor de salud | sí / no | sí | Vigila la salud de la conexión con el gateway. Por defecto: sí. |
| `fail_fast` | Fallar rápido | sí / no | no | Falla enseguida en vez de reintentar cuando el gateway no responde. Por defecto: no. |
| `suppress_network_errors` | Ocultar errores de red repetidos | sí / no | no | Reduce el ruido en el registro cuando hay fallos de red repetidos. Por defecto: no. |

### Aspecto

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `style` | Estilo de la pantalla de flujo | `clear` / `black` / `white` / `grafana` / `grafana-dark` | `clear` | Estilo de la pantalla de flujo de potencia. Por defecto: clear. |
| `neg_solar` | Permitir solar negativo | sí / no | no | Permite valores negativos de producción solar. Por defecto: no. |

### Series

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `timeseries_retention` | Retención de muestras (5 s) | texto | `24h` | Cuánto se guardan las muestras cada 5 s: 24h, 7d, 30d, 365d; 0 = ilimitado; -1 = desactivar el almacén. Por defecto: 24h. |
| `timeseries_daily_retention` | Retención de totales diarios | texto | `0` | Cuánto se guardan los totales diarios en kWh; 0 = ilimitado. Por defecto: 0. |
| `timeseries_signal_retention` | Retención de temperaturas y ventiladores | texto | `30d` | Cuánto se guardan temperaturas y ventiladores; 0 = ilimitado; -1 = no registrar. Por defecto: 30d. |
| `timeseries_signal_interval` | Intervalo de temperaturas y ventiladores | texto | `60s` | Cada cuánto se toma una muestra (mínimo 30s). Por defecto: 60s. |

### MQTT

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `mqtt_host` | Servidor MQTT | texto | vacío | Host del broker (por ejemplo core-mosquitto). Vacío = MQTT desactivado, que es el valor por defecto. |
| `mqtt_port` | Puerto MQTT | puerto (1–65535) | `1883` | Puerto del broker. Por defecto: 1883. |
| `mqtt_username` | Usuario MQTT | texto | vacío | Usuario del broker. Por defecto: vacío. |
| `mqtt_password` | Contraseña MQTT | contraseña | vacío | Contraseña del broker. Por defecto: vacía. |
| `mqtt_ha_discovery` | Autodescubrimiento en HA | sí / no | sí | Crea las entidades en Home Assistant automáticamente. Por defecto: sí. |
| `mqtt_topic_prefix` | Prefijo de topics | texto | `pypowerwall` | Prefijo de los topics MQTT. Cambiarlo cambia las entidades que se crean. Por defecto: pypowerwall. |
| `mqtt_ha_prefix` | Prefijo de descubrimiento | texto | `homeassistant` | Prefijo de descubrimiento de Home Assistant. Por defecto: homeassistant. |
| `mqtt_retain` | Mensajes retenidos | sí / no | sí | Publica los mensajes como retenidos. Por defecto: sí. |
| `mqtt_qos` | Calidad de servicio (QoS) | entero 0–2 | `1` | QoS de las publicaciones (0, 1 o 2). Por defecto: 1. |
| `mqtt_keepalive` | Keepalive (s) | entero 10–600 | `60` | Segundos de keepalive con el broker. Por defecto: 60. |
| `mqtt_client_id` | ID de cliente | texto | `pypowerwall-server` | Identificador del cliente MQTT. Por defecto: pypowerwall-server. |
| `mqtt_tls` | Usar TLS | sí / no | no | Conecta al broker con TLS. Por defecto: no. |

### Control

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `mqtt_controls` | Controles desde HA (máscara) | entero 0–31 | `0` | Activa controles en HA, bajo tu responsabilidad: 1 reserva, 2 modo, 4 carga desde red, 8 exportación, 16 islanding; se suman (15 = todo menos islanding). Necesita la clave de control y usuario y contraseña MQTT. Por defecto: 0 (solo lectura). |
| `control_secret` | Clave de control | contraseña | vacío | Activa la API /control y el panel de control de la consola. Por defecto: vacía (solo lectura). |

### Avanzado

| Opción | Nombre | Valores | Por defecto | Descripción |
|---|---|---|---|---|
| `cors_origins` | Orígenes CORS permitidos | texto | vacío | Webs externas autorizadas a llamar a la API desde el navegador (CORS), separadas por comas, por ejemplo https://a.com, https://b.com. Vacío = CORS desactivado (por defecto; la app original permite todos con *). |
| `rate_limit_enabled` | Limitar peticiones por IP | sí / no | no | Activa el límite de peticiones por IP (1000 por minuto). Por defecto: no. |
| `rate_limit_max_requests` | Límite: peticiones por ventana | entero 1–100.000 | `1000` | Peticiones permitidas por IP en cada ventana. Solo aplica con el límite activado. Por defecto: 1000. |
| `rate_limit_window_seconds` | Límite: duración de la ventana (s) | entero 1–3.600 | `60` | Duración de la ventana del límite, en segundos. Por defecto: 60. |
| `rate_limit_max_buckets` | Límite: IPs vigiladas | entero 100–1.000.000 | `10000` | Máximo de IPs que se vigilan a la vez antes de limpiar las antiguas. Por defecto: 10000. |
| `debug` | Depuración | sí / no | no | Activa el registro de depuración. Por defecto: no. |

## Controles (riesgo)

Por defecto la app es **de solo lectura**. `control_secret` activa la API `/control/*` y el panel de control de la consola;
`mqtt_controls` activa botones y números en Home Assistant (reserva, modo, carga desde red, exportación, islanding).
Úsalos **bajo tu responsabilidad**: un uso incorrecto puede provocar cortes de suministro. `mqtt_controls` necesita `control_secret`
y usuario y contraseña de MQTT.

## Datos que guarda

`/data/timeseries.db` (SQLite): muestras de 5 s (`timeseries_retention`), totales diarios (`timeseries_daily_retention`)
y temperaturas y ventiladores (`timeseries_signal_*`). Se conserva al actualizar o reiniciar el add-on.

## Solución de problemas

| Síntoma | Qué mirar |
|---|---|
| `gateway ... offline` o `Connection initialization timeout` en el registro | El host de HA no llega a `192.168.91.1`: comprueba el WiFi del gateway y haz ping desde HA |
| No conecta aunque llegue | La contraseña `pw_gw_pwd` (es la del gateway, no la de tu cuenta Tesla) |
| No aparecen entidades | `mqtt_host`, usuario y contraseña; mira `http://IP-de-HA:8677/api/mqtt/status` (`connected: true`) |
| El panel lateral sale en blanco | Abre el registro de la app: la línea `base /api/hassio_ingress/...` debe tener ese prefijo |
| Una web externa no puede llamar a la API | CORS está desactivado por defecto; añade su origen en `cors_origins` |

## Actualizaciones

Cada versión incluye notas de cambios (pestaña **Registro de cambios** y diálogo de actualización).
El número de versión de la app es el del add-on; la versión del servidor que lleva dentro se indica en las notas.
