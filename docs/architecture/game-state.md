# Game state and multiplayer

Migrated from the original project README.

## Multiplayer

1 to 4 players may take part. The first user creates the game and shares the URL. The first n−1 visitors become players; later visitors watch only.

## Client updates

Dynamic state lives in Elm `Types.Game` (`assets/elm/Types/Game.elm`): board, turn, player names, and so on. On each change the **complete state** is broadcast as JSON, compressed with lz-string, then base64-encoded via Elm ports.

## Persistence

The server stores each game in Redis as `game:<gameid>`. `gameid` is a random string at creation and is the last path segment of the URL. Idle games are removed after 24 hours.

Redis (not an Elixir process) is used so deploys do not wipe in-progress games.

## `/user` (this fork)

Theme/size preferences and finished-game history are **not** in Redis. They stay in browser `localStorage`. Move classification (hit / miss / neutral) is counted in the Elm client for the current session.

## Related

- [Architecture overview](overview.md)
- [ADR 0002](decisions/0002-browser-local-storage.md)
