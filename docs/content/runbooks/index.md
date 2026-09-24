# Runbooks

Every runbook has the same structure: **When** (trigger), **Prerequisites**, **Steps**, **Verify** and **Rollback**. That way you find the right section immediately, even under pressure.

| Runbook | When |
|---|---|
| [Talos bootstrap](talos-bootstrap.md) | Set up `home-01` from scratch (fresh install, total loss) |
| [Flux bootstrap](flux-bootstrap.md) | Right after the Talos bootstrap: install CNI, cert-manager and Flux |
| [Talos upgrade](talos-upgrade.md) | New Talos version, Renovate PR for `siderolabs/talos` |
| [Docs bucket](docs-bucket.md) | Once: set up the Garage bucket for these docs |

!!! tip "Adding a runbook"

    1. Copy an existing runbook in `docs/content/runbooks/` and rename it.
    2. Add the page to `nav` → `Runbooks` in `docs/zensical.toml`.
    3. Add a row to the table above.
