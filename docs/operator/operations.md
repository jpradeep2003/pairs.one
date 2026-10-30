# Operations — start and stop

Pid files and logs live in `.run/` (gitignored).

## App

| Task | Command |
|------|---------|
| Start Redis (if needed) + Phoenix | `scripts/start-local.sh` |
| Stop Phoenix (and Redis if this repo started it) | `scripts/stop-local.sh` |
| Logs | `.run/phoenix.log` |

Phoenix listens on http://127.0.0.1:4000. Health: `/health`.

`scripts/start-local.sh` sets `PAIRS_HOSTING=1`: no Phoenix live-reload iframe and no Brunch watcher. For live asset reload while coding, run `PAIRS_HOSTING=0 mix phx.server`.

## Cloudflare Tunnel

| Task | Command |
|------|---------|
| One-time DNS + config | `scripts/setup-cloudflare-tunnel.sh` |
| Start tunnel | `scripts/start-tunnel.sh` |
| Stop tunnel | `scripts/stop-tunnel.sh` |
| Logs | `.run/tunnel.log` |

The tunnel should point at `http://127.0.0.1:4000`. Start the app **before** the tunnel if you want a clean first request.

## Restart

```bash
scripts/stop-tunnel.sh
scripts/stop-local.sh
scripts/start-local.sh
scripts/start-tunnel.sh
```
