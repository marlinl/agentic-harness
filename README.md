# Agentic Harness

Platform-agnostic agent constraint framework with reusable skills for **Claude Code** and **OpenAI Codex**.

## Installation

### One-stop installer (recommended)

```bash
git clone https://github.com/marlinl/agentic-harness
cd agentic-harness
./install.sh
```

`install.sh` auto-detects which tools you have installed:
- Scans `~/.claude` and `~/.codex`
- Installs skills for whichever tool(s) exist
- If the repo is already cloned at `~/.agentic-harness`, checks the remote commit:
  - Same commit → skip
  - Different commit → ask before overwriting

```bash
# Project-level install
./install.sh --target ~/my-project

# Uninstall (removes symlinks, keeps the cloned repo)
./install.sh --uninstall
```

### Plugin marketplace (alternative)

**Codex:**
```bash
codex plugin marketplace add marlinl/agentic-harness
```

**Claude Code:**
```bash
/plugin marketplace add marlinl/agentic-harness
/plugin install clean-code
```

## Structure

```
agentic-harness/
├── .codex-plugin/
│   └── plugin.json           # Codex plugin manifest
├── .claude-plugin/
│   └── marketplace.json      # Claude Code plugin registry
├── .agents/
│   └── plugins/
│       └── marketplace.json  # Codex-native marketplace
├── skills/                   # Skills collection (shared by both agents)
│   ├── agent-designer/
│   │   ├── SKILL.md
│   │   └── .claude-plugin/plugin.json
│   ├── clean-code/
│   │   ├── SKILL.md
│   │   └── .claude-plugin/plugin.json
│   ├── spring-boot-patterns/
│   │   ├── SKILL.md
│   │   └── .claude-plugin/plugin.json
│   └── ...
├── AGENTS.md                 # Project-level instructions (Codex)
├── install.sh                # One-stop installer
├── LICENSE
└── README.md
```

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

## License

BSD-2-Clause
