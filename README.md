# Agentic Harness

Platform-agnostic agent constraint framework. Provides reusable skills for AI coding agents.

Supports: **Claude Code** and **OpenAI Codex CLI**.

## Installation

### Method 1: git clone (推荐)

Clone directly into the agent's skills directory — no extra steps needed.

```bash
# Codex CLI — project-level (as submodule)
git submodule add <repo-url> .agents/skills/web-engineering

# Codex CLI — user-level
git clone <repo-url> ~/.agents/skills/web-engineering

# Claude Code — project-level
git submodule add <repo-url> .claude/skills/web-engineering

# Claude Code — user-level
git clone <repo-url> ~/.claude/skills/web-engineering
```

The agent auto-discovers the root `SKILL.md` as the `web-engineering` skill collection and loads individual skills on demand.

### Method 2: install.sh

For more control (single skill, specific target, admin scope):

```bash
# Clone the harness repo first
git clone <repo-url> ~/agentic-harness

# Install all skills for Codex CLI into current project
~/agentic-harness/install.sh --adapter codex

# Install all skills for Claude Code into current project
~/agentic-harness/install.sh --adapter claude-code

# Install to user-level (available in all projects)
~/agentic-harness/install.sh --adapter codex --scope user

# Install a single skill only
~/agentic-harness/install.sh --adapter codex --skill clean-code

# Install to a specific project
~/agentic-harness/install.sh --adapter codex --target ~/my-project
```

## Skill Format

Skills use the cross-platform `SKILL.md` format:

```
skill-name/
  SKILL.md          # Instructions + metadata (required)
```

`SKILL.md` uses YAML frontmatter:

```yaml
---
name: skill-name
description: When and how to use this skill.
---
```

Both Claude Code and Codex CLI natively support this format. Skills are loaded lazily — only the full content of activated skills enters the agent's context.

## Available Skills

| Skill | Description |
|-------|-------------|
| `agent-designer` | Multi-agent architecture patterns |
| `clean-code` | DRY, KISS, YAGNI principles |
| `spring-boot-patterns` | Spring Boot best practices |
| `jpa-patterns` | JPA/Hibernate patterns and pitfalls |
| `logging-patterns` | SLF4J, structured logging, MDC |
| `maven-dependency-audit` | Dependency security scanning |
| `test-quality` | JUnit 5 + AssertJ testing |

## install.sh Options

```
./install.sh [OPTIONS]

  -a, --adapter <claude-code|codex>   Target platform (auto-detect if omitted)
  -s, --scope <repo|user|admin>       Install scope (default: repo)
  -k, --skill <name>                  Specific skill only
  -t, --target <path>                 Target directory (default: .)
```

## License

BSD-2-Clause
