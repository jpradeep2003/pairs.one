# Documentation layout

## Canonical structure

```
<repo-root>/
├── README.md                 # Short entry point only
├── LICENSE                   # Optional legal
├── CHANGELOG.md              # Optional; release history
├── config.example.yaml       # Config templates stay at root (not docs)
│
└── docs/
    ├── README.md             # Documentation index
    ├── product/
    │   ├── README.md
    │   ├── roadmap.md
    │   ├── requirements.md
    │   └── prd/
    ├── architecture/
    │   ├── README.md
    │   ├── overview.md
    │   └── decisions/
    ├── developer/
    │   ├── README.md
    │   ├── setup.md
    │   ├── configuration.md
    │   └── contributing.md
    ├── quality/
    │   ├── README.md
    │   └── testing.md
    ├── release/
    │   ├── README.md
    │   ├── build.md
    │   └── deployment.md
    ├── user/
    │   ├── README.md
    │   ├── getting-started.md
    │   └── features/
    ├── operator/
    │   ├── README.md
    │   ├── installation.md
    │   └── operations.md
    └── admin/
        ├── README.md
        └── setup.md
```

Not every page is required on day one. **Every role directory must have `README.md`** once the migration is complete.

## Naming rules

| Rule | Example |
|------|---------|
| Directories: lowercase, single word matching role | `docs/developer/` |
| Files: `kebab-case.md` | `getting-started.md` |
| ADRs: `NNNN-short-title.md` | `0001-use-sqlite-for-index.md` |
| PRDs: `feature-slug.md` under `prd/` | `prd/recommendation-engine.md` |
| Avoid dated filenames | Prefer `roadmap.md` over `roadmap-2026-q1.md` unless archiving |

## Linking rules

- Use **relative** links between docs files.
- From root README: `docs/developer/setup.md` (repo-relative).
- Cross-role: `../operator/installation.md`.
- Anchor to headings for long pages: `configuration.md#vault-settings`.
- External links: full URL, verify they resolve.

## Exemptions

These paths **may exist outside `docs/`** and should not be forcibly migrated:

| Path | Reason |
|------|--------|
| `README.md` (root) | Repository entry point |
| `LICENSE`, `CHANGELOG.md`, `CONTRIBUTING.md` | Community conventions (prefer moving CONTRIBUTING to `docs/developer/` and linking) |
| `config.example.yaml`, `.env.example` | Executable config templates |
| `.cursor/skills/**/SKILL.md` | Agent skill definitions |
| `history/` | Agent chat archive from the `dev-chat-history` skill (index, not product docs) |
| `.github/**` | GitHub templates (keep minimal; link to docs) |
| `**/README.md` inside code packages | Module pointers only — ≤ 15 lines, must link to `docs/` |

### Package / submodule READMEs

If `packages/foo/README.md` or `obsidian-plugin/README.md` exists:

1. Migrate substantive content to the appropriate `docs/<role>/` page.
2. Replace package README with:

```markdown
# <Package name>

<One sentence description.>

Full documentation: [docs/...](../../docs/developer/....md)
```

## Non-markdown artifacts

Schemas, OpenAPI specs, diagrams-as-code, and ontology files may live under `docs/`:

```
docs/
└── architecture/
    └── schemas/
        ├── api-v1.yaml
        └── README.md      # Required: explains the artifacts
```

Every non-`.md` artifact directory needs a `README.md` index.

## Anti-patterns (relocate on sight)

| Pattern | Action |
|---------|--------|
| `docs/` + duplicate `documentation/` | Merge into `docs/` |
| Root `GUIDE.md`, `SETUP.md`, `DEPLOY.md` | Move to role folder |
| `wiki/`, `notes/`, `design/` at root | Migrate or archive |
| Long README sections (>20 lines) on one topic | Extract to `docs/` |
| Multiple PRD locations | Consolidate under `docs/product/prd/` |

## docs/README.md

The docs index is the second entry point (after root README). It lists all roles with one-line descriptions and links to each `docs/<role>/README.md`. Do not duplicate the root README quick start.
