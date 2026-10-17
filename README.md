# WanGP para RunPod con RTX 4090

Construcción del Dockerfile oficial de deepbeepmeep/WanGP, fijado al commit fde3c7e10c47c854913d5877d955901a35e44714 y compilado para CUDA 8.9 (RTX 4090).

Imagen de pruebas: ghcr.io/astharok/wangp-runpod-4090:testing

Plantilla privada RunPod: 1aulwkkl68 (WanGP RTX4090 - testing).

## Configuración

- Container disk: 40 GB.
- Volume disk: 300 GB, montado en /runpod-volume.
- Aplicación: /opt/WanGP.
- Datos: /runpod-volume/wan-gp.
- HTTP 7860: interfaz web protegida por contraseña.
- HTTP 7866: MCP Streamable HTTP con OAuth.
- WANGP_DATA_DIR=/runpod-volume/wan-gp
- WANGP_ENABLE_MCP=1

Las contraseñas se generan en los registros en cada arranque. Opcionalmente usar secretos RunPod para WANGP_AUTH_PASSWORD y WANGP_MCP_AUTH_PASSWORD, con valores distintos. No guardar contraseñas en este repositorio.

MCP: https://POD-ID-7866.proxy.runpod.net/mcp. El origen se configura automáticamente con RUNPOD_POD_ID.

El disco del pod sobrevive a reinicios, pero se pierde al eliminar el pod. Para reemplazar pods se requiere un volumen de red o una copia previa. No está instalado SSH en esta primera imagen; usar la consola de RunPod.

## Validación

La etiqueta testing no implica que la imagen esté validada. Primero debe completar el build, publicarse en GHCR y probarse en una RTX 4090. Después se fija el digest y se promueve a stable.
