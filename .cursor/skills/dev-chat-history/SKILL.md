---
name: dev-chat-history
description: >-
  Harvest agent chat sessions into tagged, summarized markdown under history/.
  Discussion-centric chronological index, scope filtering for out-of-project chats,
  incremental updates via manifest.json. Use when building development history,
  chat archives, project memory, or when the user mentions history/, dev-chat-history.
disable-model-invocation: true
---

# Development chat history

Turn AI coding-session transcripts into structured, searchable markdown under `history/`.

**Primary entry point:** `history/index.md` — a **chronological list of discussions** (not sessions).

**Automation:** `scripts/build-dev-history.py` (preferred). Agents may enrich summaries manually after a script run.

**Portable:** Agent-specific session discovery is in [agent-sources.md](agent-sources.md).

## When to use

- Build, update, or refresh project development history from chat sessions
- User mentions `history/`, incremental processing, or discussion tagging
- After significant agent work, to capture decisions for future context

## Quick start

```bash
python3 scripts/build-dev-history.py          # incremental (default)
python3 scripts/build-dev-history.py --full   # full rebuild
```

Then review `history/index.md`. Enrich individual discussion files manually if summaries are too thin.

## Workflow checklist

```
- [ ] 1. Discover sessions ([agent-sources.md](agent-sources.md))
- [ ] 2. Classify scope: pkm vs excluded (wrong project, same workspace)
- [ ] 3. Parse JSONL → filter system-injected user messages
- [ ] 4. Segment into discussions; tag at discussion level
- [ ] 5. Write session tree + discussion markdown
- [ ] 6. Rebuild discussion-centric index.md and by-tag indexes
- [ ] 7. Update manifest.json; report summary
```

## Core concepts

| Concept | Description |
|---------|-------------|
| **Session** | One Cursor chat (UUID folder with `.jsonl`) |
| **Discussion** | One coherent topic — may span multiple user turns in a session |
| **Scope `pkm`** | In-repo development work → `history/sessions/` |
| **Scope `excluded`** | Different project chat in same workspace → `history/excluded/sessions/` |

Sessions are not the primary index unit. Users continue one session across unrelated topics; one logical topic may span sessions. **Anchor history on discussions.**

## Parse and segment

Canonical JSONL: `role` + `message.content[]` with `type: text` or `type: tool_use`.

**Filter** before segmenting (not real user intent):

- `Briefly inform the user about the task result...`
- `Execute the selected diff-tab commit-and-push...`
- `<dynamic_tools>` blocks

**Merge** short follow-ups ("go ahead", "yes", < 100 chars) into the current discussion.

**Split** on substantial topic change (keyword overlap < 25% + ≥ 200 chars) or explicit new-task signals.

Details: [output-layout.md](output-layout.md#segmentation-rules-script-and-manual).

## Tag discussions

One **primary** tag per discussion from [tags-and-templates.md](tags-and-templates.md). Use keyword + file-path signals (e.g. `obsidian-pkm` → product-analysis, `docs/product/prd` → docs-spec). Avoid tagging everything `dev-feature`.

## Links (critical)

Broken links are a common failure. Follow [output-layout.md](output-layout.md#link-conventions-avoid-broken-paths):

- `history/index.md` → `sessions/<id>/discussions/<slug>.md`
- `history/by-tag/<tag>/index.md` → `../../sessions/<id>/discussions/<slug>.md` (not `../sessions/`)
- Session/discussion tables → `history/sessions/...` (workspace-root-relative)

## Scope exclusion

Chats about **other projects** may appear in this repo's Cursor transcripts (same workspace, wrong topic). Exclude them:

- Known IDs in `NON_PKM_SESSION_IDS` in `scripts/build-dev-history.py`
- Heuristic: non-PKM keywords (e.g. chartered accountant, pairs.one) with no `scripts/`, `obsidian-pkm`, or `docs/product/prd` file touches

Archive under `history/excluded/`; list in index **Excluded sessions** section; omit from discussion timeline and by-tag indexes.

## Output layout

```
history/
  index.md              # chronological discussions (primary)
  sessions/<id>/        # PKM scope
  excluded/sessions/    # out-of-scope
  by-tag/<tag>/         # PKM discussions by tag
  manifest.json
```

Full schema: [output-layout.md](output-layout.md).

## Incremental updates

Default: incremental via `history/manifest.json`. Reprocess when session missing, `content_hash` changed, or `line_count` increased.

Full rebuild: `--full` — reprocess all sessions, rebuild all indexes.

Log progress to stderr: `done/total`, percent, elapsed (required for multi-session runs).

## Manual enrichment

After script run, optionally edit discussion files for richer summaries. Preserve frontmatter (`primary_tag`, `started_at`, `files_touched`). Re-running the script overwrites generated content for changed sessions.

## Acceptance criteria

- [ ] `history/index.md` lists discussions chronologically with date, title, tag
- [ ] All markdown links resolve (verify by-tag uses `../../sessions/`)
- [ ] Out-of-project sessions in `history/excluded/`, not in main timeline
- [ ] Each discussion has distinct primary tag where possible
- [ ] Incremental re-run touches only new/changed sessions
- [ ] No secrets in committed markdown

## Reference files

| File | Contents |
|------|----------|
| [agent-sources.md](agent-sources.md) | Per-agent session discovery |
| [tags-and-templates.md](tags-and-templates.md) | Tag taxonomy and summary templates |
| [output-layout.md](output-layout.md) | Layout, links, manifest, segmentation |

## Report when done

- Run mode (full / incremental)
- PKM sessions / discussions processed; excluded count
- Errors, if any
- Path to `history/index.md`
