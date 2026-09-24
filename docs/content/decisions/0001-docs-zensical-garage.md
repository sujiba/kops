# 0001 Docs with Zensical and Garage

| | |
|---|---|
| **Status** | accepted |
| **Date** | 2026-09-22 |

## Context

Operational knowledge (how-tos, incidents, decisions) was scattered across READMEs. We need searchable docs right in the infra repo, without an extra toolchain and self-hosted.

## Decision

- **Generator:** [Zensical](https://zensical.org/), successor of Material for MkDocs, configured in `docs/zensical.toml`.
- **Language:** English, like the rest of the repo (READMEs, commits, code comments).
- **Hosting:** Garage bucket `docs.offene.cloud` in website mode, served via `envoy-external`.
- **Deploy:** CI job on the in-cluster `forgejo-runner`, upload with `aws s3 sync --delete`.

## Alternatives

| Option | Why not |
|---|---|
| MkDocs + Material | Unclear future |
| Starlight / Docusaurus | Brings a Node toolchain into the infra repo |
| mdBook | Too few docs features (admonitions, tabs, cards) |
| GitHub Pages | Possible later as a second target, would need a mirror to GitHub |

## Consequences

!!! warning "Zensical is below 0.1"

    Breaking changes are possible. Fallback: ProperDocs with Material, the Markdown content stays compatible.

- **No redirects:** Garage cannot redirect. Links always point to directory URLs (`path/`), renamed pages create dead links.
- **Docs are gone when the cluster `hcloud` is down.** In an emergency, read the Markdown files directly in the repo.
- **GeoIP policy** on the gateway `envoy-external` applies to the docs as well.
