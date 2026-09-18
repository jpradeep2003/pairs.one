#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PID_DIR="${ROOT}/.run"

if [[ -f "$PID_DIR/tunnel.pid" ]]; then
  pid="$(cat "$PID_DIR/tunnel.pid")"
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid"
    echo "Stopped Cloudflare tunnel (pid ${pid})."
  else
    echo "Tunnel pid file present but process not running."
  fi
  rm -f "$PID_DIR/tunnel.pid"
else
  echo "Tunnel is not running (no pid file)."
fi
