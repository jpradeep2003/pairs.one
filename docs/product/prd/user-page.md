# User page

- **Status:** shipped
- **Owner:** local fork

## Problem

The public home page is a lobby. We want a personal surface for custom games that remembers settings and past results without accounts.

## Requirements

- Route `/user` and `/:locale/user`.
- Same custom-game Elm widget as the home page (`elm-game-selector` / `GameSettings.elm`).
- Settings already persist via `saveSettingsToLocalStorage`.
- History is written when a round completes (`saveGameHistory` Elm port) and rendered from `localStorage`.

## Out of scope

- Syncing history across browsers or devices.
- Changing the original home-page game modes besides a header link.
