# User page features

## Custom game

The selector is the same Elm widget as the home-page “Start a custom game” block, except player count is fixed at 1 and mode is **local** (those controls are hidden). Changing theme or size writes those values to `pairs-one-settings`.

## History

Each completed round stores:

| Field | Source |
|-------|--------|
| Accuracy | Same value as the solo end-of-game “Accuracy: N%” |
| Duration | End minus start (timer starts when the game page loads; resets on Replay) |
| Hits | Two-card moves that matched |
| Misses | Mismatch where the second card had already been opened |
| Neutral | Mismatch where the second card had never been opened |
| Theme | Game theme id |
| Size | Board dimension (`4x4`, `6x6`, `8x8`) |
| Start / end | ISO timestamps, shown in the browser locale |

After you finish a round you are returned to **My games** so the new history row is visible. Each row can be deleted from the table (stored only in this browser).

Key: `pairs-one-game-history` (newest first, capped at 200).
