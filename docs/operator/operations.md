# Operations — start and stop

Pid files and logs live in `.run/` (gitignored).

## App

| Task | Command |
|------|---------|
| Start Redis (if needed) + Phoenix | `scripts/start-local.sh` |
| Stop Phoenix (and Redis if this repo started it) | `scripts/stop-local.sh` |
| Logs | `.run/phoenix.log` |

Phoenix listens on http://127.0.0.1:4000. Health: `/health`.

The Brunch watcher is started without `--stdin` so the app can run as a background process.

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
