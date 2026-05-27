# Agentic Harness

Platform-agnostic agent constraint framework. Provides reusable skills, hooks, and scripts for AI coding agents.

Currently supports: **Claude Code** and **OpenAI Codex CLI**.

## Quick Start

```bash
# Install all skills for Codex CLI (repo scope)
./install.sh --adapter codex

# Install all skills for Claude Code (repo scope)
./install.sh --adapter claude-code

# Install to user-level (available in all projects)
./install.sh --adapter codex --scope user

# Install a single skill
./install.sh --adapter codex --skill clean-code
```

## Skill Format

Skills use the cross-platform `SKILL.md` format:

```
skill-name/
  SKILL.md          # Instructions + metadata (required)
  scripts/          # Optional executable scripts
  references/       # Optional reference docs
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

### web-engineering

Advanced engineering skills for Java 21/25 and Spring Boot 4 development.

| Skill | Description |
|-------|-------------|
| `agent-designer` | Multi-agent architecture patterns |
| `clean-code` | DRY, KISS, YAGNI principles |
| `spring-boot-patterns` | Spring Boot best practices |
| `jpa-patterns` | JPA/Hibernate patterns and pitfalls |
| `logging-patterns` | SLF4J, structured logging, MDC |
| `maven-dependency-audit` | Dependency security scanning |
| `test-quality` | JUnit 5 + AssertJ testing |

## Adapters

### OpenAI Codex CLI

Installs skills by copying to Codex's skill directories:

| Scope | Location |
|-------|----------|
| repo | `TARGET/.agents/skills/` |
| user | `~/.agents/skills/` |
| admin | `/etc/codex/skills/` |

### Claude Code

Installs skills by copying to Claude Code's skill directories:

| Scope | Location |
|-------|----------|
| repo | `TARGET/.claude/skills/` |
| user | `~/.claude/skills/` |

## Install Options

```
./install.sh [OPTIONS]

  -a, --adapter <claude-code|codex>   Target platform (auto-detect if omitted)
  -s, --scope <repo|user|admin>       Install scope (default: repo)
  -c, --collection <name>             Specific collection only
  -k, --skill <name>                  Specific skill only
  -t, --target <path>                 Target directory (default: .)
```

## License

BSD-2-Clause
