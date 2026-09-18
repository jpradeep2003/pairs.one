---
name: standardize-docs
description: >-
  Standardize repository documentation into role-based markdown under docs/.
  Slim root README with links per role (product, architecture, developer, quality,
  release, user, operator, admin). Consolidate or retire ad-hoc docs. Use when
  updating docs, restructuring README, creating role guides, migrating scattered
  documentation, or when the user mentions standardize-docs or documentation layout.
disable-model-invocation: true
---

# Standardize documentation

Restructure any repository so **all documentation lives under `docs/`**, and the **root `README.md` is a short entry point** that links to role-specific guides.

**Portable:** Copy this skill to `~/.cursor/skills/standardize-docs/` to use it in any repo.

## Principles

1. **Single home** — User-facing and technical docs go in `docs/`. No parallel doc trees unless explicitly exempt (see [layout.md](layout.md#exemptions)).
2. **Role-first** — Organize by who reads the doc, not by when it was written.
3. **Progressive depth** — Root README ≤ 80 lines. Details live in `docs/<role>/`.
4. **Markdown only** — `.md` for all docs. Non-markdown artifacts (OpenAPI, schemas) live in `docs/` subfolders with a companion `.md` index.
5. **No duplication** — One canonical source per topic. Link instead of copy.
6. **Living docs** — Prefer updating existing role pages over adding new top-level files.

## Roles

| Role | Audience | Primary concerns |
|------|----------|------------------|
| **product** | PM, stakeholders | Market context, user needs, requirements, roadmap, PRDs |
| **architecture** | Architect, tech leads | System design, trade-offs, ADRs, short/long-term technical direction |
| **developer** | Engineers | Setup, config, code layout, APIs, contributing, local workflows |
| **quality** | QA, testers | Test strategy, how to run tests, coverage expectations, release gates |
| **release** | Build/release engineers | Build, packaging, versioning, CI/CD, deployment |
| **user** | End users | Features, how-to, FAQs — using the product as intended |
| **operator** | SRE, ops, on-call | Running, monitoring, backups, incident response, upgrades |
| **admin** | Instance administrators | Tenant/config management, access control, integrations — distinct from day-to-day **user** tasks even when the same person wears both hats |

Role definitions and page templates: [roles.md](roles.md).

## Target layout

```
docs/
├── README.md              # Doc index (links all roles)
├── product/
├── architecture/
├── developer/
├── quality/
├── release/
├── user/
├── operator/
└── admin/
```

Full layout rules, naming, and exemptions: [layout.md](layout.md).

## Workflow

Copy this checklist and track progress:

```
- [ ] 1. Audit — inventory all existing docs (see migration.md)
- [ ] 2. Plan — map each file to docs/<role>/ destination or retirement
- [ ] 3. Scaffold — create docs/ tree and role README.md landing pages
- [ ] 4. Migrate — move/consolidate content; fix internal links
- [ ] 5. Slim README — rewrite root README from template (templates.md)
- [ ] 6. Retire — remove or stub relocated ad-hoc docs; update inbound links
- [ ] 7. Validate — link check, no orphan topics, exemptions documented
```

### Step 1: Audit

Run the inventory steps in [migration.md](migration.md#audit). Produce a migration table before editing.

**Do not delete source files until content is migrated and links are updated.**

### Step 2: Plan

For each existing doc, decide:

| Action | When |
|--------|------|
| **Move** | Content fits one role cleanly |
| **Split** | Content serves multiple roles — extract sections into separate role pages |
| **Merge** | Multiple small files cover the same topic |
| **Retire** | Superseded or duplicate — link to canonical page |
| **Exempt** | Matches an allowed exception in layout.md |

### Step 3: Scaffold

Create `docs/README.md` and each `docs/<role>/README.md` using templates in [templates.md](templates.md). Empty sections are fine; use `> TODO:` placeholders only when content is genuinely missing.

### Step 4: Migrate

- Preserve meaning; tighten prose (remove stale duplication).
- Use relative links between docs: `[Setup](../developer/setup.md)`.
- PRDs → `docs/product/prd/<slug>.md`.
- ADRs → `docs/architecture/decisions/<nnnn>-<slug>.md` (4-digit zero-padded).
- Move `docs/prd/` or scattered PRDs under `docs/product/prd/`.

### Step 5: Slim root README

Replace verbose README with [root README template](templates.md#root-readme). Keep only:

- Name + one-sentence description
- Minimal quick start (or link to `docs/developer/setup.md`)
- **Documentation** table linking each role
- License / contributing one-liners

### Step 6: Retire ad-hoc docs

For each relocated file at the old path:

- **Preferred:** delete after migration if nothing external links to it.
- **Transitional:** replace with a 3-line stub:

  ```markdown
  # Moved

  This document moved to [New Title](docs/role/page.md).
  ```

Update references in code comments, package READMEs, CI configs, and skills.

### Step 7: Validate

- [ ] Root README ≤ 80 lines
- [ ] Every `docs/<role>/README.md` exists
- [ ] No doc files outside `docs/` except exemptions in layout.md
- [ ] No broken relative links in migrated docs
- [ ] Each major README topic from the old README appears somewhere under `docs/`
- [ ] `docs/README.md` links all role landing pages

## Writing guidelines

- **Titles:** Sentence case in headings; `kebab-case.md` for filenames.
- **Audience:** Write each page for one role; cross-link instead of blending audiences.
- **Length:** Prefer several focused pages over one giant page (>300 lines → split).
- **Commands:** Copy-pasteable, with prerequisites stated once per page.
- **Config:** Reference `config.example.yaml` or env vars; never embed secrets.
- **Diagrams:** Mermaid or ASCII in markdown; no binary-only docs without a markdown summary.

## What not to do

- Do not leave long configuration tables in the root README — move to `docs/developer/configuration.md`.
- Do not create `DOCUMENTATION.md`, `GUIDE.md`, or new top-level doc files outside `docs/`.
- Do not duplicate quick-start steps across README and developer docs — README links, developer page explains.
- Do not migrate agent skills (`.cursor/skills/**/SKILL.md`) — they stay in place; link from developer docs if useful.

## Additional resources

- [roles.md](roles.md) — role responsibilities and required sections per landing page
- [layout.md](layout.md) — folder structure, naming, exemptions
- [templates.md](templates.md) — copy-paste templates for README and role pages
- [migration.md](migration.md) — audit commands and migration table format
