# Testing

Upstream has no automated tests (`mix test` only covers views/errors).

## Manual checks for this fork

1. `scripts/start-local.sh` — http://127.0.0.1:4000 loads, health at `/health`.
2. `/en/user` shows theme and size only (1 player, local; player and visibility controls hidden).
3. Change theme/size, reload `/en/user` — those choices remain. Home-page player/visibility settings stay independent.
4. Finish a 4×4 game — browser returns to `/en/user` with Accuracy (%), Duration, Hits, Misses, Neutral, Theme, Size, Start, End.
5. Delete a history row with ×; it stays gone after reload.
6. If a tunnel is up, open the HTTPS hostname, play one game over WSS.

## Related

- [Known issues](known-issues.md)
- [Operator operations](../operator/operations.md)
