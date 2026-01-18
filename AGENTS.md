<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

## Skill Creation Requirements

When creating skills, ALWAYS follow this structure:
- Directory: `.windsurf/skills/<skill-name>/`
- Main file: `SKILL.md` (UPPERCASE)
- Required frontmatter: `name` and `description` only
- Optional: `scripts/`, `references/`, `assets/` directories

FORBIDDEN:
- Creating `.md` files directly in `.windsurf/skills/`
- Lowercase `skill.md` filenames
- Extra frontmatter fields

VERIFICATION: Always check existing skills (like `skill-creator`) as templates first.

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->