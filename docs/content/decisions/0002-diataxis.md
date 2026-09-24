# 0002 Structure docs along Diátaxis

| | |
|---|---|
| **Status** | accepted |
| **Date** | 2026-09-24 |

## Context

The handbook grows page by page (runbooks, architecture, ADRs, incident logs). Without a shared model, pages drift into mixed content: steps next to long background, reference tables in the middle of a procedure. Under pressure, the reader then has to search inside a page instead of finding the right page.

[Diátaxis](https://diataxis.fr/) splits documentation by the reader's need into four types, using two questions: does the content inform **action** or **cognition**, and does it serve **acquisition** (study) or **application** (work) of a skill?

| | Acquisition (study) | Application (work) |
|---|---|---|
| **Action** | Tutorial | How-to guide |
| **Cognition** | Explanation | Reference |

## Decision

We use Diátaxis as the model for every page, adapted to a single-operator homelab:

| Section | Diátaxis type | Content |
|---|---|---|
| Runbooks | How-to guide | Goal-oriented steps for a competent operator: When, Prerequisites, Steps, Verify, Rollback |
| Reference | Reference | Building blocks and their setup (e.g. CNPG clusters, kopiur backups): what exists, where it is configured, which knobs, what it creates |
| Architecture | Explanation | How the parts fit together, diagrams |
| Decisions | Explanation | Why something is built this way, with alternatives |
| Troubleshooting | none (record) | Dated incident logs, kept outside the four types on purpose |
| Tutorials | none | No section: there are no learners to onboard |

Rules for writing:

- **One primary type per page.** The page's section decides the type.
- **Reference pages only for shared building blocks.** Components and platform services whose behavior is spread over several files or used by many apps (kopiur, CNPG, Garage). A single app's `helmrelease.yaml` is its own reference and gets no page.
- **Split by need, not by topic.** One topic can have a reference page (knobs), a runbook (restore) and an ADR (why); each links to the others.
- **The manifests under `kubernetes/` are the source of truth.** Reference pages describe the structure and link to the manifests; they never copy volatile values (versions, tags, limits).
- **Link instead of mixing.** A runbook links to a reference page for the knobs and to the architecture page or an ADR for the *why*.
- **Secondary content is collapsed.** Where a short aside is unavoidable, it goes into a `??? note` box.

## Alternatives

| Option | Why not |
|---|---|
| No model, structure ad hoc | Pages drift into mixed content, which is what this ADR fixes |
| All four types as sections | The tutorials section would stay empty |
| Reference only as the manifests themselves | YAML shows values, but not which knobs matter, how the pieces relate across files, or what the defaults mean |
| Structure by cluster or component (`hcloud/`, `home/`, `garage/`) | Mixes all four types on every page; procedures that apply to both clusters would be duplicated |

## Consequences

- New pages need a clear type; if a page does not fit any section, that is a signal to split it.
- Reference pages can go stale when manifests change. Keeping them to structure and knobs, and linking the files, limits that.
- Existing runbooks still contain lookup tables (Talos config layout, extensions and kernel args, Flux cheat sheet). They move to reference pages when those runbooks are next touched.
- Incident logs do not follow Diátaxis. They are history, not documentation, and are never rewritten.
