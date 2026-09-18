# Tags and summary templates

## Tag taxonomy

Assign one **primary** tag per discussion. Add **secondary** tags when clearly applicable.

| Tag | Description | Use when |
|-----|-------------|----------|
| `requirement-analysis` | What to build, needs, constraints, acceptance criteria | Scoping, "what should X do?", PRD-style questions |
| `arch-analysis` | System design, boundaries, data flow, trade-offs | Pipeline design, API shape, integration patterns |
| `market-analysis` | Competitive landscape, alternatives, positioning | Comparing tools/products, build vs buy |
| `product-analysis` | UX, workflows, prioritization, user-facing behavior | Plugin panels, CLI UX, user journeys |
| `tech-analysis` | Libraries, protocols, algorithms, performance | Embeddings, SQLite, MCP vs REST |
| `dev-routine-tasks` | Setup, config, installs, scripts, housekeeping | MCP setup, env, watchers, git/CI |
| `dev-problem-solving` | Debugging, root cause, fixes | Broken behavior, test failures, incidents |
| `dev-feature` | New capability end-to-end | New endpoint, enricher, plugin view |
| `dev-refactor` | Restructure without changing outward behavior | Renames, module splits, deduplication |
| `testing-qa` | Tests, verification, test plans | unittest, integration tests, manual checks |
| `docs-spec` | PRDs, README, skills, rules | `docs/`, SKILL.md, cursor rules |
| `meta-tooling` | Agent workflow, prompts, automation about the project | History builds, skills, agent harness |

Update `history/tags.md` with definitions and 1–2 example links per tag after first run.

---

## Discussion frontmatter

```yaml
---
session_id: <uuid>
discussion_slug: <kebab-slug>
source_agent: cursor | claude-code | codex | other
primary_tag: dev-feature
secondary_tags: [arch-analysis, product-analysis]
started_at: 2026-09-04T17:46:00+05:30   # omit if unknown
title: Short human title
status: completed | ongoing | abandoned
outcomes:
  - Concrete result 1
files_touched:
  - scripts/related_common.py
  - obsidian-pkm-related/src/RelatedView.ts
---
```

---

## Templates by primary tag

### requirement-analysis

```markdown
## Problem statement
## Stakeholder / user intent
## Requirements gathered
- **Must**: ...
- **Should**: ...
- **Nice**: ...
## Constraints and non-goals
## Open questions
## Key user requests
## Agent actions
## Outcomes
```

### arch-analysis

```markdown
## Context
## Options considered
## Decision and rationale
## Architecture (mermaid optional)
## Implications and follow-ups
## Key user requests
## Agent actions
## Outcomes
```

### market-analysis

```markdown
## Question
## Alternatives reviewed
## Comparison
| Option | Pros | Cons |
|--------|------|------|
## Recommendation
## Key user requests
## Agent actions
## Outcomes
```

### product-analysis

```markdown
## User workflow
## Feature / UX decisions
## Success criteria
## Deferred items
## Key user requests
## Agent actions
## Outcomes
```

### tech-analysis

```markdown
## Question
## Approaches evaluated
## Technical trade-offs
## Chosen approach and why
## Key user requests
## Agent actions
## Outcomes
```

### dev-routine-tasks

```markdown
## Task
## Steps performed
## Commands / files
## Verification
## Key user requests
## Outcomes
```

### dev-problem-solving

```markdown
## Symptom
## Investigation
## Root cause
## Fix applied
## Verification
## Key user requests
## Agent actions
## Outcomes
```

### dev-feature | dev-refactor | testing-qa | docs-spec | meta-tooling

```markdown
## Goal
## Approach
## Changes
### Files and decisions
## Outcome
## Follow-ups
## Key user requests
## Agent actions
```

---

## raw-extract.md format

```markdown
# Raw extract — <session-id>

**Source**: <agent> — `<source-file-basename>`
**Lines**: N

## Timeline

### Turn 1 — User
> User message excerpt...

### Turn 2 — Assistant
**Tools**: Read(path), Grep(pattern)
**Summary**: One sentence on what the agent did.

### Turn 3 — Assistant (subagent: explore)
**Linked file**: subagents/<id>.jsonl
**Summary**: ...
```

Keep tool inputs concise; expand only when critical to the discussion.

---

## Segmentation heuristics

| Signal | Action |
|--------|--------|
| System-injected user line (task result boilerplate, commit UI, `<dynamic_tools>`) | **Skip** — not a user discussion |
| Short follow-up ("go ahead", "yes", < 100 chars) | **Merge** into current discussion |
| New `<user_query>` with low topic overlap + ≥ 200 chars | **New** discussion |
| "Now let's..." / "New feature" / "Phase A" | **New** discussion |
| Same feature, continued debugging | **Same** discussion |
| Subagent explores same parent task | Fold into parent discussion or note in Agent actions |

When uncertain, prefer **fewer, richer** discussions over over-splitting.

## Tagging heuristics

Tags apply to **discussions**, not whole sessions. Combine:

1. **Keywords** in user turns (see taxonomy table)
2. **File paths** touched (`obsidian-pkm` → product-analysis, `import-` → dev-feature, `docs/product/prd` → docs-spec)
3. **Avoid** defaulting everything to `dev-feature` — pick the most specific matching tag
