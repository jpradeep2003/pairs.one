# User page features

## Custom game

The selector is the same Elm widget as the home-page “Start a custom game” block. Changing theme, size, players, or visibility writes `pairs-one-settings` in localStorage.

## History

Each completed round stores:

| Field | Source |
|-------|--------|
| Score | Player scores joined with `-` |
| Duration | End minus start (timer starts when the game page loads; resets on Replay) |
| Start / end | ISO timestamps, shown in the browser locale |
| Theme | Game theme id |
| Size | Board dimension (`4x4`, `6x6`, `8x8`) |

Key: `pairs-one-game-history` (newest first, capped at 200).
