---
name: add-docs
description: Use when creating or updating the cluster documentation in docs/ — app docs mirroring kubernetes/<cluster>/apps, bootstrap or infrastructure pages, or recording a design decision ("document X", "update the docs for X")
---

# Add or Update Documentation

Creates and updates the Zensical documentation in `docs/content/`. All rules for structure, page format and content live in `docs/AGENTS.md` — read it completely before starting; this skill only describes the workflow. When in doubt, mirror the reference app instead of inventing structure:

| Reference                                    | Shows                                                             |
| -------------------------------------------- | ----------------------------------------------------------------- |
| `docs/content/apps/services/vaultwarden.md`  | Complete single-page app doc, incl. an app in **both** clusters   |
| `docs/content/apps/services/index.md`        | Group index with the Namespace and Cluster(s) columns             |
| `docs/templates/`                            | Skeletons for every page type — always start from these           |

## Step 1: Gather details

Ask the user (AskUserQuestion) for anything not already given:

1. **Target** — an app (`<namespace>/<app>`), a namespace, a bootstrap topic or an infrastructure topic
2. **Scope** — new docs, update after a manifest change, removal, or a design decision to record

## Step 2: Document an app

1. Read `docs/AGENTS.md`.
2. Check **both** clusters: `ls kubernetes/home/apps/<namespace>/<app> kubernetes/hcloud/apps/<namespace>/<app>`. One doc set covers every instance.
3. Read all manifests of every instance (`ks.yaml`, HelmRelease, SOPS secrets — key names only, PVCs, database, routes, components). Consult upstream documentation only when the manifests do not explain a setting.
4. Pick the app's group (`platform`, `observability` or `services`) via the membership rule in `docs/AGENTS.md`. If `docs/content/apps/<group>/<app>.md` does not exist, create it from `docs/templates/app.md` — one single page per app, never a folder with sub-pages.
5. Fill all sections from the manifests (including the `Namespace:` line). Mark anything you cannot derive with `<!-- TODO: ... -->`.
6. Add or update the app (with its namespace and cluster(s)) in the group's `index.md` table, and remove it from the group index TODO comment if listed there.
7. If the change reflects a design choice, add an H3 entry at the top of the page's `## Decisions` section (`git log --follow` on the app directory often reveals the date and context).
8. Update the manual table of contents of every page you changed.

**Changed app:** update only the affected sections, in the same change as the manifests.

**Removed app:** if removed from all clusters, delete the app page and its row in the group `index.md`; if removed from one cluster, update the `Clusters:` line and the group table.

## Step 3: Document bootstrap or infrastructure

1. Start from `docs/templates/page.md`.
2. Place the page in `docs/content/bootstrap/` or `docs/content/infrastructure/`.
3. Link it from the section `index.md`.

## Step 4: Verify

```bash
cd docs && python3 -m venv .venv 2>/dev/null; .venv/bin/pip install -q -r requirements.txt && .venv/bin/zensical build --clean
```

Fix all warnings, then go through the "Before finishing" checklist in `docs/AGENTS.md`. Commit style: `feat(docs): ...` for new pages, `chore(docs): ...` for updates.

## Common mistakes

- **Documenting only one cluster's instance** — ~15 apps run in both `home` and `hcloud`; always check both trees (Step 2.2).
- **Copying volatile manifest values** — image tags, chart versions, resource limits and replica counts go stale; link the manifest instead.
- **Writing secret values or resolved domains** — only secret names, SOPS file paths and key names; hostnames always use `${EXTERNAL_DOMAIN}` / `${INTERNAL_DOMAIN}` style variables.
- **Forgetting the group index or the manual TOC** — every app change touches the group `index.md`, and every heading change must be mirrored in the page's `## Overview` list.
- **Grouping by namespace** — docs are grouped by function (`platform` / `observability` / `services`), not by namespace; the namespace is recorded on the app's `index.md` and in the group table.
- **Inventing page types or skipping templates** — `app.md`, `group-index.md` and `page.md` are the only page types; start every new page from `docs/templates/`.
- **Creating sub-pages for an app** — each app is exactly one page; configuration, troubleshooting and decisions are H2 sections, not separate files.
