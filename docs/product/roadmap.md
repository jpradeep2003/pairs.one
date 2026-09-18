# Roadmap

## Milestone 1 — Host ourselves

Run this Phoenix app on a MacBook and expose it on an HTTPS hostname via Cloudflare Tunnel. Cloud, Docker, Kubernetes, and GCloud are deferred.

## Milestone 2 — `/user` enhancements

A dedicated `/user` page reuses the home-page custom-game selector, remembers theme/size/players/visibility in the browser, and lists finished-game history (score, duration, start, end, theme, size) in `localStorage`.

## Later

- Cloud hosting (Docker/Kubernetes/GCloud) when Mac hosting is no longer enough
- Tests (upstream still has none)
