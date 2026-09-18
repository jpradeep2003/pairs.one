# Testing

Upstream has no automated tests (`mix test` only covers views/errors).

## Manual checks for this fork

1. `scripts/start-local.sh` — http://127.0.0.1:4000 loads, health at `/health`.
2. `/en/user` shows the custom-game selector (same controls as home).
3. Change theme/size/players/visibility, reload `/en/user` — choices remain.
4. Start a 4x4 solo/custom game, finish it — history row appears on `/en/user`.
5. If a tunnel is up, open the HTTPS hostname, play one game over WSS.

## Related

- [Operator operations](../operator/operations.md)
