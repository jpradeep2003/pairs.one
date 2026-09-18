# Agent-specific session sources

This skill is **agent-agnostic**. Before parsing, detect which environment you are in and use the matching source. If multiple sources exist, merge by `session_id` and prefer the richest transcript (usually local JSONL over search snippets).

## Detection order

1. User explicitly names the agent or path → use that.
2. Check for known transcript directories on disk (tables below).
3. Use agent-native search/export APIs if available.
4. Ask the user to export or paste the transcript path.

---

## Cursor

### Local transcripts (canonical)

```
~/.cursor/projects/<project-slug>/agent-transcripts/
  <session-uuid>/
    <session-uuid>.jsonl          # parent conversation
    subagents/
      <subagent-uuid>.jsonl       # spawned subagents
```

**Project slug**: Derived from workspace path, e.g. `/Users/you/dev/pkm` → `Users-you-dev-pkm` (slashes → hyphens, often lowercase).

**Discovery**:

```bash
# Replace PROJECT_SLUG with your slug
find ~/.cursor/projects/PROJECT_SLUG/agent-transcripts -name '*.jsonl' 2>/dev/null
```

Or glob from workspace: `~/.cursor/projects/*/agent-transcripts/**/*.jsonl` and filter by project.

### Conversation search (secondary)

Cursor agents may have `SearchConversations` (local + cached cloud index). Use for:

- Session titles and snippets when JSONL is missing
- Cloud agent runs not yet on disk

Search with short keyword queries (`pkm`, `retrieval`, feature names). **Prefer JSONL** when both exist.

### Subagent linking

- Parent spawns subagents via `Task` tool_use in parent JSONL.
- Match `subagents/*.jsonl` under the same `<session-uuid>/` folder.
- Attribute subagent work to the parent session; mention in `session.md` and parent discussion if same topic.

---

## Claude Code (CLI / desktop)

### Typical local storage

Claude Code stores project-scoped data under:

```
~/.claude/projects/<encoded-project-path>/
```

Filenames and layout vary by version. Look for:

- `*.jsonl` conversation logs
- `sessions/` or `conversations/` subdirectories
- JSON exports with `role` / `content` fields

**Discovery**:

```bash
# Encode path: replace / with - (Claude often uses full path encoding)
ls -la ~/.claude/projects/ 2>/dev/null
find ~/.claude/projects -name '*.jsonl' 2>/dev/null | head -50
```

### Normalization

Claude exports may use:

- `role`: `user` | `assistant`
- `content`: string or array of blocks (`type: text`, `type: tool_use`)

Map blocks to the canonical event types in SKILL.md before writing `raw-extract.md`.

### Export fallback

If auto-discovery fails:

```bash
# User may export from Claude Code UI or use /export-style commands when available
```

Ask user for path to exported JSON/JSONL.

---

## OpenAI Codex (CLI / IDE)

Codex session storage depends on product surface:

| Surface | Likely location |
|---------|-----------------|
| Codex CLI | Check `~/.codex/`, `~/.config/codex/`, or project `.codex/` |
| ChatGPT / API threads | No local JSONL unless user exported |

**Discovery**:

```bash
find ~/.codex ~/.config/codex -name '*.jsonl' -o -name '*.json' 2>/dev/null | head -30
ls -la .codex 2>/dev/null
```

### Normalization

Codex logs may differ from Cursor JSONL. Map:

- User prompts → `user_request`
- Assistant text → `assistant_message`
- Shell/file tools → `tool_call` with `name` + args summary

If only terminal scrollback exists, ask user to re-run with logging or export.

---

## Generic / other agents

### User-provided exports

Accept:

- JSONL (one message per line)
- JSON array of messages
- Markdown exports with clear User/Assistant headings

Place exports in a project folder the user specifies, e.g. `history/imports/<agent>/`, then process with the same pipeline.

### GitHub Copilot Chat / VS Code

Often no local transcript file. Options:

- Copy chat from UI into `history/imports/manual/<date>-<topic>.md`
- Use extension export if available

### Aider, Continue, Windsurf, etc.

Search project and home config:

```bash
find . -path '*/.aider*' -o -path '*/.continue/*' 2>/dev/null | head -20
```

Document the path you find in `history/README.md` for repeatability.

---

## Unified session record

Regardless of agent, normalize to:

```yaml
session_id: string          # UUID or stable hash of source path
source_agent: cursor | claude-code | codex | other
source_files:
  - path: absolute or import-relative
    kind: parent | subagent
    mtime: ...
    line_count: ...
    content_hash: sha256
```

## Multi-agent projects

If the same repo was developed with Cursor and Claude Code:

1. Process each agent's transcripts separately.
2. Use distinct `source_agent` in manifest.
3. Use the same `history/sessions/` layout; prefix session IDs if collisions occur (`cursor-<uuid>`, `claude-<uuid>`).

## Wrong-project sessions in the right workspace

Cursor stores transcripts per **workspace**, not per logical project. A chat about a different product (e.g. CA agent eval, a bookmark helper) may appear under this repo's `agent-transcripts/` if that chat was opened in this workspace.

**Do not** mix these into the PKM discussion timeline. Classify as `excluded` and archive under `history/excluded/sessions/`. See [output-layout.md](output-layout.md#scope-pkm-vs-excluded).

---

## What not to use as primary source

- Git commit messages alone (supplement only)
- Partial copy-paste without structure
- Cloud-only indexes without full tool-call detail (use as title/snippet fallback)
