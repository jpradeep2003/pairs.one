# Build

```bash
mix deps.get
cd assets && npm install && npm run deploy && cd ..
mix phx.digest   # production static digest
```

Development uses Brunch watchers from `mix phx.server`.
