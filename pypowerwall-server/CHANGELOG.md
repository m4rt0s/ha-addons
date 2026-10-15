# Registro de cambios

## 0.11.2

- **CORS desactivado por defecto.** Antes la app permitía llamadas desde cualquier web (`*`). Ahora `cors_origins` viene vacío y bloquea CORS; añade orígenes separados por comas si los necesitas. El panel de la barra lateral y la consola no se ven afectados.
- Nueva pestaña **Documentación** (cómo funciona, requisitos, primeros pasos, tabla de todas las opciones con sus valores por defecto y solución de problemas).
- Nueva descripción en la ficha de la app, icono y logo.
- Este registro de cambios.

## 0.11.1

- Nuevas opciones: `health_check`, `fail_fast`, `suppress_network_errors`, `cors_origins`, `rate_limit_max_requests`, `rate_limit_window_seconds` y `rate_limit_max_buckets`.
- 39 opciones en total, todas con nombre y descripción en español e inglés.

## 0.11.0

- Más de 20 ajustes de la app como opciones de la interfaz (rendimiento, aspecto, series de datos, MQTT y control), con su valor por defecto rellenado y descritos en la propia pantalla de configuración.
- Solo se envían a la app los valores con contenido: dejar un campo vacío usa el valor por defecto de la app.
- Aviso en el registro si activas `mqtt_controls` sin `control_secret`.

## 0.10.3

- La consola se abre directamente en `/console` desde el panel y el botón *Abrir interfaz web*.
- Detección más robusta de la ruta de Ingress (la consola ya carga con estilos y scripts dentro de Home Assistant).

## 0.10.2

- Nueva opción `gateway_name`: nombre del dispositivo en Home Assistant (por defecto de la app: *Default Gateway*).

## 0.10.1

- Panel **Powerwall** en la barra lateral (Ingress) y botón *Abrir interfaz web*.

## 0.10.0

- Primera versión: PyPowerwall Server 0.10.0 como app de Home Assistant con opciones de gateway, zona horaria y MQTT.
