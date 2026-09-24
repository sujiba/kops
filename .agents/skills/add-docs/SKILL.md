---
name: add-docs
description: Use when creating or updating the English operations handbook in docs/ — how-tos (runbooks), reference pages for building blocks (CNPG, kopiur, ...), architecture diagrams, design decisions (ADRs) or incident logs, including turning an existing README into a how-to ("document X", "write a how-to for X", "write a runbook for X", "make this README a how-to", "record decision X")
---

# Add or Update Documentation

Rules (language, layout, links, what not to write) are in `.agents/instructions/docs.instructions.md`, so read them first. This skill is the workflow.

| Section | New page | Template | Overview table |
| --- | --- | --- | --- |
| How-to | `docs/content/how-to/<name>.md` | `how-to/index.md` | `how-to/index.md` |
| Reference | `docs/content/reference/<name>.md` | `reference/index.md` | `reference/index.md` |
| Architecture | extend `docs/content/architecture/index.md` | Mermaid `flowchart LR` | none |
| Decision (ADR) | `docs/content/decisions/NNNN-<title>.md` | `decisions/index.md` | `decisions/index.md` |
| Incident log | `docs/content/incidents/YYYY-MM-DD-<topic>.md` | `incidents/index.md` | `incidents/index.md` |

## Steps

1. **Scope.** Ask the user (AskUserQuestion) for section and topic if not given.
2. **Facts.** Derive everything from the repo:
   - Manifests: `kubernetes/<cluster>/apps/`, bootstrap: `kubernetes/bootstrap/<cluster>/` (`2_talos` = topf, `3_flux` = helmfile).
   - Check **both** clusters (`hcloud`, `home`). If a procedure differs per cluster, use content tabs (`=== "hcloud"` / `=== "home"`) or `<cluster>` placeholders; if it only applies to one, say so in the **When** row.
   - Mark anything you cannot derive with `<!-- TODO: ... -->` and tell the user.
3. **Write** the page from the section's template.
   - How-tos: the property table (When / Duration / Risk), then `## Prerequisites` (task list), `## Steps` (numbered, commands in fenced `bash` blocks with all flags such as `--kubeconfig ~/.kube/<cluster>`), `## Verify`, `## Rollback`. Lookup material (knobs, config layout, cheat sheets) belongs on a reference page; link it from the how-to.
   - Reference: describe structure and knobs, link the manifests with full repo URLs (`https://code.offene.cloud/homelab/kops/src/branch/main/kubernetes/...`), never copy versions or tags.
   - Link related pages to each other (e.g. Talos bootstrap → Flux bootstrap, how-to → reference page).
4. **Register** the page in `nav` in `docs/zensical.toml` and add a row to the section's overview table.
5. **Build**: from `docs/`, `uv run --no-project --with-requirements requirements.txt zensical build --clean` must print `No issues found`.
6. **Report** to the user what is new, what you derived yourself (Verify/Rollback, durations) and what differs from the source.

## Turning a README into a how-to

- The README is the source, not the spec: check every path, file name and flag against the repo and fix what is wrong (wrong directory, wrong cluster in `--kubeconfig`, outdated commands). List each correction in the report.
- Restructure it into the how-to sections; lookup tables (options, extensions, config layout) go onto a reference page, background into `??? note` boxes or an ADR.
- Do not change or delete the README unless the user asks; `kubernetes/**` may be off-limits for the current task.

## Common mistakes

- **Inventing Verify/Rollback steps**: only add what follows from the repo or official docs, and flag it as your own addition.
- **Guessing tool behavior**: check the tool's docs (e.g. `topf secrets` writes and encrypts `secrets.yaml` itself, no `>` redirect).
- **Forgetting the overview table**: `nav` alone is not enough.
- **Mid-word breaks in tables**: already handled by `docs/content/stylesheets/extra.css`; do not add inline HTML or `<br>` to work around table layout.
