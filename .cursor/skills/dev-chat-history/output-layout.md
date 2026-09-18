# Output layout and manifest

All artifacts are **markdown** except `manifest.json`. Default root: `history/` at repository root.

## Directory tree

```
history/
  README.md
  index.md                    # primary entry — chronological discussions
  tags.md
  manifest.json
  sessions/                   # in-scope PKM development
    <session-id>/
      session.md
      raw-extract.md
      discussions/
        <discussion-slug>.md
  excluded/sessions/          # out-of-scope chats (wrong project, same workspace)
    <session-id>/
      ...
  by-tag/
    <tag>/
      index.md
  imports/                    # optional: user/agent exports before processing
    <agent>/
```

## Primary navigation: discussions, not sessions

**`history/index.md` is the main entry point.** It lists **discussions** in reverse chronological order (newest first), not sessions.

Sessions are a transport artifact (one Cursor chat). Discussions are the unit of meaning — a coherent topic that may span multiple user turns in one session. The same logical topic may appear in different sessions over time; the index still lists each discussion separately with its date and title.

```markdown
## Discussions (chronological)

| Date | Title | Tag | Session |
|------|-------|-----|---------|
| Tuesday, Sep 8, 2026 | [Harness dev history](sessions/5eaff55d.../discussions/i-want-to-harness....md) | `meta-tooling` | [5eaff55d](sessions/5eaff55d.../session.md) |
```

Excluded sessions appear in a separate **Excluded sessions** section with links to `excluded/sessions/<id>/session.md`.

## Link conventions (avoid broken paths)

Markdown link targets must resolve from where the file is opened. Use these rules:

| From | Link to discussion | Link to session |
|------|-------------------|-----------------|
| `history/index.md` | `sessions/<id>/discussions/<slug>.md` | `sessions/<id>/session.md` |
| `history/by-tag/<tag>/index.md` | `../../sessions/<id>/discussions/<slug>.md` | `../../sessions/<id>/session.md` |
| `history/sessions/<id>/session.md` | `history/sessions/<id>/discussions/<slug>.md` | — |
| `history/sessions/<id>/discussions/<slug>.md` | — | `history/sessions/<id>/session.md` |
| `history/excluded/...` | `history/excluded/sessions/<id>/discussions/<slug>.md` | `history/excluded/sessions/<id>/session.md` |

**Do not** use `../sessions/` from `by-tag/<tag>/` (resolves to `history/by-tag/sessions/` — broken).

**Do not** use bare `discussions/<slug>.md` in indexes; use repo-root paths (`history/sessions/...`) in session tables when the viewer resolves from workspace root.

## history/by-tag/<tag>/index.md

PKM discussions only (excluded sessions omitted). Chronological within tag.

```markdown
# Tag: dev-feature

| Date | Title | Discussion | Session |
|------|-------|------------|---------|
| 2026-09-04 | Retrieval debug panel | [title](../../sessions/6a638022.../discussions/a-note-has-to-go-through....md) | [6a638022](../../sessions/6a638022.../session.md) |
```

## Scope: PKM vs excluded

Before writing, classify each session:

| Scope | Meaning | Output path |
|-------|---------|-------------|
| `pkm` | Development work for this repo | `history/sessions/<id>/` |
| `excluded` | Chat ran in this workspace but different project | `history/excluded/sessions/<id>/` |

Exclude when session ID is in the known list, or heuristic: strong non-PKM signals (e.g. "chartered accountant", "pairs.one", "deepeval") with no PKM file touches.

Record in `manifest.json`:

```json
"excluded": {
  "<session-id>": {
    "reason": "CA agent eval — different project",
    "at": "2026-09-08T04:30:00Z"
  }
}
```

Each session entry also has `"scope": "pkm" | "excluded"`.

## manifest.json schema

```json
{
  "version": 1,
  "last_full_run_at": "2026-09-08T04:30:00Z",
  "last_incremental_run_at": "2026-09-08T04:30:00Z",
  "source_agent": "cursor",
  "project_slug": "Users-jpradeep2003-dev-pkm",
  "sessions": {
    "<session-id>": {
      "processed_at": "2026-09-08T04:30:00Z",
      "source_agent": "cursor",
      "scope": "pkm",
      "title": "...",
      "date": "Friday, Sep 4, 2026, 5:46 PM (UTC+5:30)",
      "source_files": {
        "agent-transcripts/<session-id>/<session-id>.jsonl": {
          "mtime": 1756972800.0,
          "line_count": 667,
          "content_hash": "abc123..."
        }
      },
      "discussion_slugs": ["retrieval-debug-panel"],
      "tags": ["dev-feature", "product-analysis"]
    }
  },
  "excluded": { },
  "skipped": { }
}
```

### Change detection

Reprocess when any `source_files` entry has different `content_hash`, higher `line_count`, or new file path.

## Discussion frontmatter

```yaml
---
session_id: <uuid>
discussion_slug: <kebab-slug>
source_agent: cursor
primary_tag: dev-feature
secondary_tags: [product-analysis]
started_at: "Friday, Sep 4, 2026, 5:46 PM (UTC+5:30)"
title: Short human title
status: completed
outcomes: []
files_touched: [scripts/related_common.py]
---
```

## session.md template

```markdown
# <Session title>

| Field | Value |
|-------|-------|
| Session ID | `<uuid>` |
| Source agent | cursor |
| Scope | pkm |
| Date range | ... |
| Transcript | `agent-transcripts/<uuid>/` |

## Discussions

| Date | Title | Tag | Discussion |
|------|-------|-----|------------|
| Sep 4, 2026 | Retrieval debug panel | dev-feature | [title](history/sessions/<id>/discussions/<slug>.md) |
```

## Segmentation rules (script and manual)

Filter out system-injected user lines before segmenting:

- `Briefly inform the user about the task result...`
- `Execute the selected diff-tab commit-and-push...`
- `<dynamic_tools>` payloads

Merge into the **same discussion** when the user message is:

- Short follow-up (< 100 chars): "go ahead", "yes", "fix that"
- Continuation prefix: "can you", "also", "now", "wait,"

Start a **new discussion** when:

- Substantial new topic (low keyword overlap with prior discussion + ≥ 200 chars), or
- Explicit signal: "New feature", "Let's continue with", "Phase A", numbered new task

## Automation

`scripts/build-dev-history.py` implements discovery, scope classification, segmentation, tagging, and index generation.

```bash
python3 scripts/build-dev-history.py          # incremental
python3 scripts/build-dev-history.py --full   # full rebuild
```

## Incremental run algorithm

```
1. sessions_all = discover(agent_sources)
2. manifest = read_or_create(history/manifest.json)
3. todo = all sessions (full) or changed/missing (incremental)
4. for s in todo:
     classify scope (pkm | excluded)
     parse → filter system messages → segment → tag → write
     update manifest.sessions[s] and manifest.excluded if needed
5. rebuild index.md (discussion timeline), tags.md, by-tag/*/index.md
6. write last_*_run_at
```
