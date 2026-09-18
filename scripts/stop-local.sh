#!/usr/bin/env bash
# Stop Phoenix (and Redis only if this repo started it).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PID_DIR="${ROOT}/.run"

stop_pidfile() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    local pid
    pid="$(cat "$file")"
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Stopped ${label} (pid ${pid})."
    else
      echo "${label} pid file present but process not running."
    fi
    rm -f "$file"
  else
    echo "${label} is not running (no pid file)."
  fi
}

stop_pidfile "$PID_DIR/phoenix.pid" "Phoenix"
stop_pidfile "$PID_DIR/redis.pid" "Redis started by this repo"

# Phoenix watchers (brunch) may outlive the mix parent
pkill -f "node_modules/brunch/bin/brunch watch" 2>/dev/null || true
