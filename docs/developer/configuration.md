# Configuration

| Key | Where | Purpose |
|-----|--------|---------|
| `MIX_ENV` | env | Use `dev` on the Mac host |
| `PAIRS_HOSTING` | `scripts/start-local.sh` (default `1`) | Disables live-reload and Brunch watch so the public board stays clickable |
| Redis URI | `config` / `REDIS_URI` in prod | Default `redis://localhost:6379/0` |
| `SECRET_KEY_BASE` | `config/dev.exs` or env in prod | Cookie signing |
| `PHX_HOST` | prod runtime | Public hostname |
| Tunnel config | `~/.cloudflared/pairs-one-tunnel.yml` | Cloudflare ingress |
| `js_app_src` | `ViewHelpers` | Cache-bust query on `/js/app.js` (bump `?v=` when history JS changes) |
| `pairs-one-settings` | browser localStorage | Theme/size (and on the home page: players/visibility) |
| `pairs-one-game-history` | browser localStorage | Finished games on `/user` |

Do not commit tunnel credential JSON, `*.local.exs` secrets, `.run/`, or `graphify-out/`.
