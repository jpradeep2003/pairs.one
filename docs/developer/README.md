# Developer documentation

**Audience:** Engineers running and changing this repo.

## Pages

| Page | Description |
|------|-------------|
| [Setup](setup.md) | Toolchain and first run |
| [Configuration](configuration.md) | Env, assets, localStorage keys |
| [Translations](i18n.md) | Adding gettext and Elm locales |
| [Contributing](contributing.md) | UI reuse, Graphify, chat history |

Agent skills live under `.cursor/skills/` ([standardize-docs](../../.cursor/skills/standardize-docs/SKILL.md), [dev-chat-history](../../.cursor/skills/dev-chat-history/SKILL.md)). Graphify indexes code in `graphify-out/` (gitignored). Run Elm from `assets/elm/`, not `assets/` — stray `assets/elm-package.json` / `assets/elm-stuff/` are gitignored.
