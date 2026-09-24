# Decisions

Architecture decision records (ADRs) capture **why** something is built the way it is. An ADR is not rewritten once accepted: if the decision changes, a new ADR replaces the old one, and the old one gets the status "superseded by NNNN".

| No. | Title | Status |
|---|---|---|
| [0001](0001-docs-zensical-garage.md) | Docs with Zensical and Garage | accepted |
| [0002](0002-diataxis.md) | Structure docs along Diátaxis | accepted |

## Template

File name: `NNNN-short-title.md`, numbered sequentially. Then add it to `nav` in `docs/zensical.toml`.

```markdown
# NNNN Title

| | |
|---|---|
| **Status** | proposed / accepted / superseded by NNNN |
| **Date** | YYYY-MM-DD |

## Context

Which problem, which constraints?

## Decision

What we do.

## Alternatives

| Option | Why not |
|---|---|
| … | … |

## Consequences

What becomes easier, harder or riskier as a result.
```
