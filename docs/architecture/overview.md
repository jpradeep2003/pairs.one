# System overview

```mermaid
flowchart LR
  browser[Browser]
  cf[Cloudflare Tunnel]
  phx[Phoenix :4000]
  redis[Redis]
  browser -->|HTTPS / WSS| cf --> phx
  phx --> redis
```

- **UI:** Phoenix templates plus Elm (`Game.elm`, `GameSettings.elm`).
- **Realtime:** Phoenix channels over websocket; game JSON compressed with lz-string.
- **Game state:** Redis keys `game:<id>`, removed after 24 hours idle.
- **`/user` extras:** Not stored on the server. Settings and history stay in `localStorage`.

Upstream notes on multiplayer and i18n remain accurate; see the original README content migrated here and in [developer](../developer/README.md).
