#!/usr/bin/env bash
# Start Redis (if needed) and the Phoenix app on http://127.0.0.1:4000
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PID_DIR="${ROOT}/.run"
mkdir -p "$PID_DIR"

export MIX_ENV="${MIX_ENV:-dev}"
export PATH="${HOME}/.local/elm-0.18.0/darwin-x64:${HOME}/.local/bin:${HOME}/.local/elixir-1.15.7/bin:/opt/homebrew/opt/erlang@26/bin:/opt/homebrew/bin:${HOME}/.asdf/shims:${PATH}"

if ! command -v redis-cli >/dev/null 2>&1; then
  echo "redis-cli not found. Install Redis: brew install redis" >&2
  exit 1
fi

if ! redis-cli ping >/dev/null 2>&1; then
  if command -v redis-server >/dev/null 2>&1; then
    redis-server --daemonize yes --dir "$PID_DIR" --pidfile "$PID_DIR/redis.pid" --logfile "$PID_DIR/redis.log"
    sleep 1
  else
    echo "Redis is not running and redis-server is not installed." >&2
    exit 1
  fi
fi

if ! redis-cli ping >/dev/null 2>&1; then
  echo "Redis did not respond to PING." >&2
  exit 1
fi

if ! command -v mix >/dev/null 2>&1; then
  echo "mix not found. Install Elixir 1.15 (see docs/developer/setup.md)." >&2
  exit 1
fi

if [[ -f "$PID_DIR/phoenix.pid" ]] && kill -0 "$(cat "$PID_DIR/phoenix.pid")" 2>/dev/null; then
  echo "Phoenix already running (pid $(cat "$PID_DIR/phoenix.pid"))."
  exit 0
fi

export ROOT PID_DIR MIX_ENV PATH
python3 - <<'PY'
import os, subprocess
from pathlib import Path
root = Path(os.environ["ROOT"])
pid_dir = root / ".run"
log = open(pid_dir / "phoenix.log", "ab")
proc = subprocess.Popen(
    ["mix", "phx.server"],
    cwd=str(root),
    stdin=subprocess.DEVNULL,
    stdout=log,
    stderr=subprocess.STDOUT,
    start_new_session=True,
    env=os.environ.copy(),
)
(pid_dir / "phoenix.pid").write_text(str(proc.pid))
print(f"Started Phoenix (pid {proc.pid}). Logs: {pid_dir / 'phoenix.log'}")
print("Local URL: http://127.0.0.1:4000")
PY
