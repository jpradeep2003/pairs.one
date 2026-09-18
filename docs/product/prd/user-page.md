# User page

- **Status:** shipped
- **Owner:** local fork

## Problem

The public home page is a lobby. We want a personal surface for custom games that remembers theme/size and past results without accounts.

## Requirements

- Route `/user` and `/:locale/user`.
- Custom-game widget locked to **1 player** and **local** (player and visibility controls hidden).
- Theme and size persist in `pairs-one-settings` without overwriting home-page player/visibility.
- On complete: save history, then redirect to `/user`.
- History columns: Accuracy, Duration, Hits, Misses, Neutral, Theme, Size, Start, End; rows deletable.

## Out of scope

- Syncing history across browsers or devices.
- Changing the original home-page game modes besides a **My games** header link.
