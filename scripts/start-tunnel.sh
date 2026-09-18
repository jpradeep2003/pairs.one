#!/usr/bin/env bash
# Start Cloudflare Tunnel for the local Phoenix app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PID_DIR="${ROOT}/.run"
mkdir -p "$PID_DIR"

CONFIG="${CLOUDFLARED_CONFIG:-$HOME/.cloudflared/pairs-one-tunnel.yml}"
CLOUDFLARED="${CLOUDFLARED:-/opt/homebrew/bin/cloudflared}"

if [[ ! -x "$CLOUDFLARED" ]]; then
  echo "cloudflared not found. Install: brew install cloudflared" >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Tunnel config missing: ${CONFIG}" >&2
  echo "Create it with: scripts/setup-cloudflare-tunnel.sh" >&2
  exit 1
fi

if [[ -f "$PID_DIR/tunnel.pid" ]] && kill -0 "$(cat "$PID_DIR/tunnel.pid")" 2>/dev/null; then
  echo "Tunnel already running (pid $(cat "$PID_DIR/tunnel.pid"))."
  exit 0
fi

export PID_DIR CONFIG CLOUDFLARED
python3 - <<'PY'
import os, subprocess
from pathlib import Path
pid_dir = Path(os.environ["PID_DIR"])
log = open(pid_dir / "tunnel.log", "ab")
proc = subprocess.Popen(
    [os.environ["CLOUDFLARED"], "tunnel", "--config", os.environ["CONFIG"], "run"],
    stdin=subprocess.DEVNULL,
    stdout=log,
    stderr=subprocess.STDOUT,
    start_new_session=True,
    env=os.environ.copy(),
)
(pid_dir / "tunnel.pid").write_text(str(proc.pid))
print(f"Started Cloudflare tunnel (pid {proc.pid}). Logs: {pid_dir / 'tunnel.log'}")
PY
