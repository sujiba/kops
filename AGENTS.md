@.agents/instructions/sorting.instructions.md

Reusable task skills (add-app, add-docker-app, add-docs, ...) live in .agents/skills/; Claude Code discovers them through the .claude/skills symlink.

## Documentation

When changing anything under kubernetes/<cluster>/apps/<namespace>/<app>, update the matching documentation under docs/content/apps/ in the same change, using the add-docs skill (.agents/skills/add-docs/SKILL.md). Rules live in docs/AGENTS.md.
