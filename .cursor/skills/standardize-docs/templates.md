# Documentation templates

Copy and adapt. Replace `ProjectName` and placeholders. Delete unused role rows/sections.

---

## Root README

Target: **≤ 80 lines**. Link out for everything else.

```markdown
# ProjectName

One-sentence description of what this project does and who it is for.

## Quick start

1. Clone and install — see [Developer setup](docs/developer/setup.md).
2. Copy `config.example.yaml` to `config.yaml` and set required values.
3. Run `<primary dev command>`.

## Documentation

| Role | Guide |
|------|-------|
| Product | [Requirements & roadmap](docs/product/README.md) |
| Architecture | [System design & decisions](docs/architecture/README.md) |
| Developer | [Setup, config & contributing](docs/developer/README.md) |
| Quality | [Testing](docs/quality/README.md) |
| Release | [Build & deploy](docs/release/README.md) |
| User | [Using the product](docs/user/README.md) |
| Operator | [Running in production](docs/operator/README.md) |
| Admin | [Instance administration](docs/admin/README.md) |

## License

See [LICENSE](LICENSE).
```

Remove table rows for roles that do not apply (e.g. omit `operator/` for a library with no deployed service).

---

## docs/README.md

```markdown
# Documentation

Documentation is organized by role. Start with the guide that matches your job.

| Role | Description | Guide |
|------|-------------|-------|
| Product | Requirements, roadmap, PRDs | [product/](product/README.md) |
| Architecture | System design and ADRs | [architecture/](architecture/README.md) |
| Developer | Local setup and development | [developer/](developer/README.md) |
| Quality | Testing and verification | [quality/](quality/README.md) |
| Release | Build, CI/CD, deployment | [release/](release/README.md) |
| User | End-user features and how-tos | [user/](user/README.md) |
| Operator | Production operations | [operator/](operator/README.md) |
| Admin | Instance configuration and governance | [admin/](admin/README.md) |
```

---

## Role landing page (`docs/<role>/README.md`)

```markdown
# <Role title> documentation

**Audience:** <who should read this>

**You will find:** <bullet list of what this section covers>

## Pages

| Page | Description |
|------|-------------|
| [Page name](page.md) | One line |
| ... | ... |

## Related

- [Other role](../other-role/README.md) — when to read that instead
```

---

## ADR (`docs/architecture/decisions/NNNN-title.md`)

```markdown
# NNNN. Title

- **Status:** proposed | accepted | deprecated | superseded by [NNNN](NNNN-other.md)
- **Date:** YYYY-MM-DD
- **Deciders:** names or roles

## Context

What problem or force motivates this decision?

## Decision

What we chose.

## Consequences

Positive, negative, and neutral outcomes.
```

---

## PRD (`docs/product/prd/<slug>.md`)

```markdown
# <Feature name>

- **Status:** draft | review | approved | shipped
- **Owner:** name or role

## Problem

What user or business problem does this solve?

## Goals

- Goal 1

## Non-goals

- Explicitly out of scope

## Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| R1 | ... | must |

## Success metrics

How we know this worked.

## Open questions

- ...
```

---

## Runbook (`docs/operator/runbooks/<slug>.md`)

```markdown
# <Incident or procedure>

## Symptoms

What triggers this runbook?

## Impact

User-visible or business impact.

## Diagnosis

1. Step
2. Step

## Mitigation

1. Step
2. Step

## Follow-up

Post-incident actions.
```

---

## Transitional stub (old path after move)

```markdown
# Moved

This document moved to [<Title>](<relative-path-to-new-doc>).
```
