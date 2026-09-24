---
icon: lucide/siren
---

# Runbooks

Every runbook has the same structure: **When** (trigger), **Prerequisites**, **Steps**, **Verify** and **Rollback**. That way you find the right section immediately, even under pressure.

| Runbook | When |
|---|---|
| [Talos bootstrap](talos-bootstrap.md) | Set up `home-01` from scratch (fresh install, total loss) |
| [Flux bootstrap](flux-bootstrap.md) | Right after the Talos bootstrap: install CNI, cert-manager and Flux |
| [Talos upgrade](talos-upgrade.md) | New Talos version, Renovate PR for `siderolabs/talos` |
| [Docs bucket](docs-bucket.md) | Once: set up the Garage bucket for these docs |

## Template

File name: `short-title.md`. Then add it to `nav` → `Runbooks` in `docs/zensical.toml` and add a row to the table above.

```markdown
# Title

| | |
|---|---|
| **When** | Trigger, and which cluster it applies to |
| **Duration** | about N minutes |
| **Risk** | Low / Medium / High: what is affected |

## Prerequisites

- [ ] …

## Steps

1. …

## Verify

Commands and the expected result.

## Rollback

How to undo it, or why it is not needed.
```
