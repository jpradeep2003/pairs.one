# Configuration

| Key | Where | Purpose |
|-----|--------|---------|
| `MIX_ENV` | env | Use `dev` on the Mac host |
| Redis URI | `config` / `REDIS_URI` in prod | Default `redis://localhost:6379/0` |
| `SECRET_KEY_BASE` | `config/dev.exs` or env in prod | Cookie signing |
| `PHX_HOST` | prod runtime | Public hostname |
| Tunnel config | `~/.cloudflared/pairs-one-tunnel.yml` | Cloudflare ingress |

Do not commit tunnel credential JSON or `*.local.exs` secrets.
