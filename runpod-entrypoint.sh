#!/usr/bin/env bash
set -euo pipefail
APP_DIR=/opt/WanGP
DATA_DIR=${WANGP_DATA_DIR:-/runpod-volume/wan-gp}
export WANGP_DATA_DIR="$DATA_DIR"
if [ "${WANGP_ENABLE_MCP:-0}" = 1 ]; then
  : "${RUNPOD_POD_ID:?RUNPOD_POD_ID is required for authenticated MCP}"
  export WANGP_EXTRA_ARGS="--mcp-webui --mcp-host 0.0.0.0 --mcp-port 7866 --mcp-transport streamable-http --mcp-api-version 2.1 --mcp-auth --mcp-auth-url https://${RUNPOD_POD_ID}-7866.proxy.runpod.net ${WANGP_EXTRA_ARGS:-}"
fi
mkdir -p "$DATA_DIR"/{ckpts,loras,outputs,settings,workspaces,config,deepy_sessions,user_skills,cache/huggingface,cache/torch,cache/triton}
for name in ckpts loras outputs settings workspaces deepy_sessions user_skills; do
  if [ -L "$APP_DIR/$name" ]; then
    [ "$(readlink "$APP_DIR/$name")" = "$DATA_DIR/$name" ] || { echo "Unexpected link: $name"; exit 1; }
  elif [ -d "$APP_DIR/$name" ]; then
    cp -an "$APP_DIR/$name/." "$DATA_DIR/$name/"
    mv "$APP_DIR/$name" "$APP_DIR/${name}.image-defaults"
    ln -s "$DATA_DIR/$name" "$APP_DIR/$name"
  elif [ ! -e "$APP_DIR/$name" ]; then
    ln -s "$DATA_DIR/$name" "$APP_DIR/$name"
  else
    echo "Unexpected application path: $name"; exit 1
  fi
done
chown -R user:user "$DATA_DIR"
export HOME=/home/user
export PYTHONUNBUFFERED=1
export HF_HOME="$DATA_DIR/cache/huggingface"
export TORCH_HOME="$DATA_DIR/cache/torch"
export TRITON_CACHE_DIR="$DATA_DIR/cache/triton"
export OMP_NUM_THREADS="$(nproc)"
export MKL_NUM_THREADS="$(nproc)"
export OPENBLAS_NUM_THREADS="$(nproc)"
export NUMEXPR_NUM_THREADS="$(nproc)"
export TORCH_ALLOW_TF32_CUBLAS=1
export TORCH_ALLOW_TF32_CUDNN=1
export SDL_AUDIODRIVER=dummy
export PULSE_RUNTIME_PATH=/tmp/pulse-runtime
nvidia-smi
cd "$APP_DIR"
exec su -p user -c 'python3 wgp.py \
  --listen \
  --server-port 7860 \
  --auth \
  --profile 4 \
  --attention sage2 \
  --config "$WANGP_DATA_DIR/config" \
  --settings "$WANGP_DATA_DIR/settings" \
  --loras "$WANGP_DATA_DIR/loras" \
  --output-dir "$WANGP_DATA_DIR/outputs" \
  --workspaces-dir "$WANGP_DATA_DIR/workspaces" \
  ${WANGP_EXTRA_ARGS:-}'
