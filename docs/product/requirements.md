# Requirements

## Must

- Operators can start and stop the app on a Mac with documented commands.
- Operators can publish the local app on a Cloudflare Tunnel hostname (HTTPS).
- Players can open `/user` (and `/:locale/user`).
- `/user` uses the same custom-game widget as home, locked to 1 player and local (those controls hidden).
- Theme and size persist in the browser (`pairs-one-settings`) without overwriting home-page player/visibility.
- Finished games append history in the browser (`pairs-one-game-history`).
- History fields: accuracy, duration, hits, misses, neutral, theme, size, start time, end time. Rows can be deleted in the browser.
- Visual changes reuse existing templates, Elm widgets, and CSS.

## Should

- A “My games” link from the existing header.

## Nice

- Cloud deployment runbooks.

## Non-goals (now)

- Docker, Kubernetes, and GCloud.
- Server-side accounts or history storage.
