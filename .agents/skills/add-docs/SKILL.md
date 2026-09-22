---
name: add-docs
description: Use when creating or updating the German operations handbook in docs/ — runbooks, architecture diagrams, design decisions (ADRs) or incident logs ("document X", "write a runbook for X", "record decision X")
---

# Add or Update Documentation

The handbook is a Zensical project rooted at `docs/`: config `docs/zensical.toml`, pages `docs/content/`. Language is German. Rules are in `.agents/instructions/docs.instructions.md` — read it first.

| Section | Path | Template / overview |
| --- | --- | --- |
| Runbook | `docs/content/runbooks/<name>.md` | copy `runbooks/talos-upgrade.md`; table in `runbooks/index.md` |
| Architecture | `docs/content/architecture/index.md` | Mermaid flowcharts, real component names |
| Decision (ADR) | `docs/content/decisions/NNNN-<title>.md` | template in `decisions/index.md` |
| Incident log | `docs/content/troubleshooting/JJJJ-MM-TT-<topic>.md` | template in `troubleshooting/index.md` |

## Steps

1. Ask the user (AskUserQuestion) for the section and topic if not given.
2. Derive facts from the manifests under `kubernetes/` and `kubernetes/bootstrap/`; check **both** clusters (`hcloud`, `home`). Mark anything you cannot derive with `<!-- TODO: ... -->`.
3. Write the page from the section's template. Runbooks keep the structure Wann / Voraussetzungen / Schritte / Prüfen / Rollback.
4. Add the page to `nav` in `docs/zensical.toml` and a row to the section's `index.md` table.
5. Verify: `cd docs && uv run --no-project --with-requirements requirements.txt zensical build --clean` — must report no issues.

## Common mistakes

- **Wall of text** — use tables, admonitions and `??? note` boxes instead of long prose.
- **Editing old ADRs or incident logs** — write a new one that references the old one.
- **Absolute or extension-less links** — use relative `.md` links; Garage cannot redirect.
- **Copying volatile values** — image tags, chart versions and resource limits go stale; link the manifest instead.
- **Writing secret values** — only secret names and key names.
- **Forgetting `nav`** — pages missing from `nav` do not show up in the navigation.
