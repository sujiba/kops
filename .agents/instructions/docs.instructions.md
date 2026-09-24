# Documentation instructions

English operations handbook built with Zensical. `docs/` is the docs project root: config in `docs/zensical.toml`, pages in `docs/content/`, build output in `docs/site/` (ignored). Published to the Garage bucket `docs.offene.cloud`.

- Page types follow Diátaxis (ADR 0002): runbooks (`runbooks/`) are how-to guides, reference pages (`reference/`) describe shared building blocks such as CNPG clusters or kopiur backups (not single apps) and link to the manifests under `kubernetes/`, architecture (`architecture/`) and ADRs (`decisions/`) are explanation, incident logs (`troubleshooting/`) are records. One primary type per page; link to the other types instead of mixing, short asides go into collapsed `??? note` boxes. Each section's `index.md` holds the template and the overview table.
- No wall of text: overview pages are short tables with links, background goes into `??? note` boxes, warnings into admonitions.
- Garage cannot redirect: link to other pages with relative `.md` links, never rename published pages without need.
- ADRs and incident logs are not rewritten after the fact; supersede them with a new entry.
- No volatile values (image tags, chart versions, resource limits); link the manifest instead. No secret values, only secret and key names.
- Every new page must be added to `nav` in `docs/zensical.toml` and to its section's overview table.
- Version pinned in `docs/requirements.txt`. From `docs/`: live preview with `uv run --no-project --with-requirements requirements.txt zensical serve`, verify with `uv run --no-project --with-requirements requirements.txt zensical build --clean`; fix all warnings.

Use the add-docs skill (.agents/skills/add-docs/SKILL.md) for the workflow.
