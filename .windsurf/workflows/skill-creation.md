---
description: Enforce proper skill creation structure and validation
auto_execution_mode: 3
---
<!-- OPENSPEC:START -->
**Guardrails**
- ALWAYS check existing skills structure before creating new ones
- NEVER create .md files directly in .windsurf/skills/ directory
- ALWAYS use proper directory structure: .windsurf/skills/<skill-name>/SKILL.md
- ALWAYS verify SKILL.md has proper frontmatter before proceeding

**Steps**
1. **Verify existing patterns** - Check .windsurf/skills/ for existing compliant examples
2. **Validate directory structure** - Ensure skill is created as subdirectory, not direct file
3. **Check filename** - Verify main file is named SKILL.md (uppercase)
4. **Validate frontmatter** - Ensure only required fields (name, description) are present
5. **Test skill invocation** - Verify skill can be invoked with @<skill-name>

**Error Recovery**
- If structure is wrong, delete and recreate properly
- If frontmatter is invalid, fix before proceeding
- Always reference skill-creator as the template example
<!-- OPENSPEC:END -->
