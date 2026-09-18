#!/usr/bin/env bash
# One-time: create a named Cloudflare tunnel and DNS route for this Mac.
set -euo pipefail

CLOUDFLARED="${CLOUDFLARED:-/opt/homebrew/bin/cloudflared}"
TUNNEL_NAME="${TUNNEL_NAME:-pairs-one}"
HOSTNAME="${PAIRS_HOSTNAME:-pairs.pspark.online}"
CONFIG="${CLOUDFLARED_CONFIG:-$HOME/.cloudflared/pairs-one-tunnel.yml}"
LOCAL_URL="${LOCAL_URL:-http://127.0.0.1:4000}"

if [[ ! -x "$CLOUDFLARED" ]]; then
  echo "cloudflared not found. Install: brew install cloudflared && cloudflared login" >&2
  exit 1
fi

uuid="$("$CLOUDFLARED" tunnel list 2>/dev/null | awk -v name="$TUNNEL_NAME" '$2 == name { print $1; exit }')"
if [[ -z "$uuid" ]]; then
  "$CLOUDFLARED" tunnel create "$TUNNEL_NAME"
  uuid="$("$CLOUDFLARED" tunnel list 2>/dev/null | awk -v name="$TUNNEL_NAME" '$2 == name { print $1; exit }')"
fi

if [[ -z "$uuid" ]]; then
  echo "Could not determine tunnel UUID for ${TUNNEL_NAME}." >&2
  exit 1
fi

"$CLOUDFLARED" tunnel route dns "$TUNNEL_NAME" "$HOSTNAME" || true

cat > "$CONFIG" <<EOF
# pairs.one — Cloudflare Tunnel (Mac host)
tunnel: ${uuid}
credentials-file: ${HOME}/.cloudflared/${uuid}.json

ingress:
  - hostname: ${HOSTNAME}
    service: ${LOCAL_URL}
  - service: http_status:404
EOF

echo "Wrote ${CONFIG}"
echo "Hostname: https://${HOSTNAME}"
echo "Start with: scripts/start-tunnel.sh"
