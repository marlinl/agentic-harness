# Agentic Harness

Platform-agnostic agent constraint framework with reusable skills for Java web engineering.

## Available Skills

| Skill | When to use |
|-------|-------------|
| `agent-designer` | Designing multi-agent systems, agent architectures |
| `clean-code` | Writing or refactoring code (DRY, KISS, YAGNI) |
| `spring-boot-patterns` | Controllers, services, repos, REST APIs |
| `jpa-patterns` | JPA performance, lazy loading, N+1 |
| `test-quality` | Writing tests, improving coverage |
| `logging-patterns` | Setting up logging, structured logs |
| `maven-dependency-audit` | Auditing dependencies, security scanning |

## Adding a New Skill

1. Create `skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter
2. Keep the skill focused on one job
3. Add the skill to the table in `skills/SKILL.md` and this file
4. Test with Codex: restart and verify the skill appears in `/skills`
