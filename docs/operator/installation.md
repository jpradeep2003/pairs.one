# Installation (Mac)

1. Install Redis, Elixir/OTP 26, Node, Elm 0.18, and Hex (`mix local.hex`).
2. `mix deps.get` and `cd assets && npm install`.
3. One-time Cloudflare login: `cloudflared login`
4. Create DNS + config: `scripts/setup-cloudflare-tunnel.sh`

Default public hostname: `pairs.pspark.online` (override with `PAIRS_HOSTNAME`).

Cloudflare Tunnel needs a named tunnel credential file under `~/.cloudflared/`. Do not commit it.
