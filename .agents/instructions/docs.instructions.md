# Documentation instructions

English operations handbook built with Zensical. `docs/` is the docs project root: config in `docs/zensical.toml`, pages in `docs/content/`, build output in `docs/site/` (ignored). Published to the Garage bucket `docs.offene.cloud`.

- Page types: runbooks (`runbooks/`), architecture (`architecture/`), ADRs (`decisions/`), incident logs (`troubleshooting/`). Each section's `index.md` holds the template and the overview table.
- No wall of text: overview pages are short tables with links, background goes into `??? note` boxes, warnings into admonitions.
- Garage cannot redirect: link to other pages with relative `.md` links, never rename published pages without need.
- ADRs and incident logs are not rewritten after the fact; supersede them with a new entry.
- Every new page must be added to `nav` in `docs/zensical.toml` and to its section's overview table.
- Version pinned in `docs/requirements.txt`. From `docs/`: live preview with `uv run --no-project --with-requirements requirements.txt zensical serve`, verify with `uv run --no-project --with-requirements requirements.txt zensical build --clean`; fix all warnings.

Use the add-docs skill (.agents/skills/add-docs/SKILL.md) for the workflow.
