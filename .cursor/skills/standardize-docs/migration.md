# Documentation migration

Use this when applying the skill to an existing repository.

## Audit

### 1. Find documentation files

```bash
# Markdown outside docs/ (review each hit)
find . -name '*.md' \
  -not -path './docs/*' \
  -not -path './.git/*' \
  -not -path './node_modules/*' \
  -not -path './.cursor/skills/*' \
  -not -path './history/*' \
  | sort

# Existing docs/ tree
find docs -name '*.md' 2>/dev/null | sort

# Large README (line count)
wc -l README.md
```

### 2. Classify each file

| Source | Likely destination |
|--------|-------------------|
| Root README sections | Split across roles; keep short intro + links |
| `docs/prd/*` | `docs/product/prd/*` |
| `CONTRIBUTING.md` | `docs/developer/contributing.md` |
| `DEPLOY*.md`, `docker/*` notes | `docs/release/` or `docs/operator/` |
| API / MCP docs | `docs/developer/api.md` |
| Plugin user guides | `docs/user/features/` |
| Remote ops / HTTPS setup | `docs/operator/` |
| Config tables in README | `docs/developer/configuration.md` |
| Design notes, ontology | `docs/architecture/` (+ artifact README) |

### 3. Migration table

Produce this **before** editing (in chat or a scratch file — do not commit the table unless the user asks):

| Current path | Action | Destination | Notes |
|--------------|--------|-------------|-------|
| `README.md` | slim + link | root (rewritten) | Move config tables → developer |
| `docs/foo.md` | move | `docs/role/bar.md` | |
| `packages/x/README.md` | stub | keep ≤15 lines | Link to docs |

Actions: `move` | `split` | `merge` | `retire` | `exempt`

## Migration order

1. Create `docs/<role>/README.md` shells (no content loss yet).
2. Migrate leaf content pages (deepest / most self-contained first).
3. Update cross-links between new pages.
4. Rewrite root README and `docs/README.md`.
5. Stub or delete old paths.
6. Update inbound references: other markdown, comments, `package.json` links, CI docs, skills.

## Splitting a verbose README

For each `## Section` in the old README:

1. Assign one primary role (see roles.md).
2. If >30 lines or mixed audiences → dedicated page under that role.
3. If purely a link list → fold into role README.
4. Leave in root README only: title, description, 3-step quick start, documentation table, license.

## Link validation

```bash
# Quick check for broken relative links (manual review of output)
# Re-run after migration; fix any reported broken targets.

rg '\]\([^)]+\.md[^)]*\)' docs/ README.md --no-heading
```

For each link target, confirm the file exists. Prefer `rg` or a markdown link checker if the repo has one in CI.

## Common repo patterns

| Pattern | Guidance |
|---------|----------|
| Monorepo with per-package READMEs | Stub package READMEs; centralize in `docs/developer/` |
| Existing `docs/prd/` | Rename to `docs/product/prd/` |
| `ARCHITECTURE.md` at root | → `docs/architecture/overview.md` |
| Obsidian / PKM-style skills in `.cursor/skills/` | Exempt; mention in `docs/developer/README.md` |
| Generated docs | Do not hand-edit; document generation in `docs/developer/` and add to `.gitignore` if appropriate |

## Completion criteria

- [ ] Migration table executed (every row resolved)
- [ ] No substantive doc content only in root README
- [ ] `find` audit shows only exempt paths outside `docs/`
- [ ] User can reach any former topic via role navigation
- [ ] User reviewed changes (required before merge if migrating a shared repo)
