# Documentation roles

Each role has a **landing page** at `docs/<role>/README.md`. The landing page orients the reader and links to detail pages. Do not duplicate the root README.

## product

**Readers:** Product managers, founders, business stakeholders.

**Covers:**

- Problem statement and target users
- Market context (brief — link out for deep research)
- User requirements and acceptance criteria
- Roadmap (near-term milestones, longer themes)
- PRDs (`docs/product/prd/`)

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Index + how to read product docs |
| `roadmap.md` | Time-horizon plan |
| `requirements.md` | Cross-cutting requirements |
| `prd/<feature>.md` | One PRD per major feature or initiative |

**Not here:** Implementation detail, API reference, deployment runbooks.

---

## architecture

**Readers:** Architects, tech leads, senior engineers making system-level choices.

**Covers:**

- System context and component overview
- Key technical constraints and non-functional requirements
- Architecture Decision Records (ADRs)
- Short-term vs long-term technical direction
- Integration boundaries and data flows

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Architecture index |
| `overview.md` | C4-style or narrative system overview |
| `decisions/<nnnn>-<slug>.md` | ADRs (status: proposed / accepted / deprecated) |
| `integrations.md` | External systems and contracts |

**Not here:** Step-by-step dev setup, user how-tos, test case lists.

---

## developer

**Readers:** Engineers contributing to or extending the codebase.

**Covers:**

- Prerequisites and local setup
- Repository layout and key modules
- Configuration reference (`config.example.yaml`, env vars)
- Development workflows (run, debug, test locally)
- API / CLI reference for developers
- Contributing guidelines

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Developer index |
| `setup.md` | Clone, install, first run |
| `configuration.md` | All config keys and conventions |
| `architecture-for-developers.md` | Code map (link to architecture/ for decisions) |
| `contributing.md` | PR process, style, hooks |
| `api.md` | HTTP/CLI/MCP surfaces |

**Not here:** Production runbooks, end-user feature tours.

---

## quality

**Readers:** QA engineers, developers writing tests, release gate owners.

**Covers:**

- Test strategy (unit, integration, e2e, manual)
- How to run the test suite and interpret results
- Coverage expectations and gaps
- Test data and fixtures
- Pre-release verification checklist

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Quality index |
| `testing.md` | Commands, frameworks, patterns |
| `test-plan.md` | Scope and scenarios for major releases |

---

## release

**Readers:** Build engineers, release managers, CI maintainers.

**Covers:**

- Build and packaging
- Versioning scheme
- CI/CD pipelines
- Artifact publishing
- Deployment procedures (link to operator/ for runtime ops)
- Changelog maintenance

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Release index |
| `build.md` | Local and CI builds |
| `deployment.md` | Deploy steps per environment |
| `versioning.md` | Semver / calendar / custom scheme |

**Note:** Root `CHANGELOG.md` is allowed (see layout.md). `docs/release/` should link to it.

---

## user

**Readers:** People using the product to accomplish tasks (not administering it).

**Covers:**

- Getting started from a user perspective
- Feature guides and workflows
- FAQs and limitations
- Keyboard shortcuts, UI concepts

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | User guide index |
| `getting-started.md` | First successful use |
| `features/<topic>.md` | Deep dives per feature area |

**Not here:** Server installation, API keys for operators, database backups.

---

## operator

**Readers:** People who keep the application running in an environment (SRE, DevOps, self-hosters).

**Covers:**

- Installation and upgrades in production-like environments
- Process supervision, health checks, restarts
- Logging, metrics, alerting
- Backups and disaster recovery
- Capacity and performance tuning
- Incident response playbooks

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Operations index |
| `installation.md` | Production install |
| `operations.md` | Day-2 operations |
| `monitoring.md` | Observability |
| `runbooks/<incident>.md` | Focused incident guides |

**Distinction from release:** Release owns *how artifacts are built and promoted*; operator owns *how they run reliably*.

---

## admin

**Readers:** Instance or tenant administrators (may overlap with user in single-user deployments).

**Covers:**

- Initial admin setup and bootstrap
- User/account management (when multi-user)
- Security settings, API keys, integrations
- Data export/import, retention policies
- Feature flags or per-tenant configuration

**Typical pages:**

| Page | Purpose |
|------|---------|
| `README.md` | Admin index |
| `setup.md` | First-time admin configuration |
| `security.md` | Auth, keys, permissions |
| `integrations.md` | Third-party connections from an admin view |

**Distinction from user:** User docs explain *using features*; admin docs explain *configuring and governing* the instance.

**Single-user products:** Keep both `user/` and `admin/` — admin pages cover vault paths, API keys, automation watchers; user pages cover note-taking workflows.
