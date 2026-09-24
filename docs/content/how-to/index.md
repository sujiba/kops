---
icon: lucide/user-cog
---

# How-Tos

Every how-to has the same structure: **When** (trigger), **Prerequisites**, **Steps**, **Verify** and **Rollback**. That way you find the right section immediately, even under pressure.

| How-to | When |
|---|---|
| [Talos bootstrap](talos-bootstrap.md) | Set up `home-01` from scratch (fresh install, total loss) |
| [Flux bootstrap](flux-bootstrap.md) | Right after the Talos bootstrap: install CNI, cert-manager and Flux |
| [Talos upgrade](talos-upgrade.md) | New Talos version, Renovate PR for `siderolabs/talos` |
| [Garage bucket](garage-bucket.md) | New S3 bucket in Garage: public for static sites and CDN, private for backups |

## Template

File name: `short-title.md`. Then add it to `nav` → `How-Tos` in `docs/zensical.toml` and add a row to the table above.

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
