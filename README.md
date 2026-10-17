# WanGP para RunPod con RTX 4090

Esta configuración construye el `Dockerfile` oficial de WanGP fijando:

- WanGP commit: `fde3c7e10c47c854913d5877d955901a35e44714`
- Arquitectura CUDA: `8.9` (RTX 4090)
- Imagen: `ghcr.io/<usuario>/wangp-runpod-4090:stable`

## Configuración de la plantilla RunPod

- Tipo: Pod / NVIDIA GPU
- Container disk: 40 GB
- Volume disk inicial: 300 GB
- Mount path: `/runpod-volume`
- HTTP: `7860`
- TCP: `22`

La aplicación vive en `/opt/WanGP`; el volumen persistente no puede montarse
encima de ese directorio. Los datos se guardan en
`/runpod-volume/wan-gp`.

El acceso web se inicia con autenticación:

```text
python wgp.py --listen --server-port 7860 --auth
```

La contraseña web se suministra mediante el secreto `WANGP_AUTH_PASSWORD`.
El servidor MCP se añadirá después de validar el arranque web y se publicará
con autenticación independiente, mediante `WANGP_MCP_AUTH_PASSWORD`.

## Actualizaciones

No sustituir el commit por `main`. Primero se prueba el nuevo commit en una
etiqueta de prueba y, después de validar generación y persistencia, se promueve
a `stable`.
