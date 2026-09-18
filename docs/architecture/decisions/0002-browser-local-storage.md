# 0002. Store user options and history in the browser

- **Status:** accepted
- **Date:** 2026-09-18

## Context

`/user` must remember custom-game choices and finished-game history without accounts.

## Decision

Keep using the existing `pairs-one-settings` localStorage key for the Elm game selector. Add `pairs-one-game-history` for completed rounds, written from an Elm port when `isCompleted` becomes true.

## Consequences

- Data is per browser profile and is lost if storage is cleared.
- No extra Redis schema or auth.
- Multi-device history is not available.
