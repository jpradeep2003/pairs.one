# Developer setup

## Prerequisites

- Erlang/OTP 26 (`brew install erlang@26`) and Elixir 1.15 (precompiled zip under `~/.local/elixir-1.15.7`, see `.tool-versions`)
- Node.js (Brunch; Node 16 is safer than 24 if the watcher fails)
- Elm 0.18 (`~/.local/elm-0.18.0/darwin-x64` on PATH; x86_64 binary via Rosetta)
- Redis
- Hex (`mix local.hex`)

`scripts/start-local.sh` prepends Elixir, Erlang@26, and Elm 0.18 to `PATH`.

## First run

```bash
mix deps.get
cd assets && npm install && cd ..
scripts/start-local.sh
```

Open http://127.0.0.1:4000

Stop with `scripts/stop-local.sh`.

## Layout

- `lib/pairs_one_web/` — Phoenix router, controllers, templates
- `assets/elm/` — game UI (`Game.elm`, `GameSettings.elm`)
- `assets/js/app.js` — ports, localStorage
- `scripts/` — start/stop and Cloudflare tunnel helpers
