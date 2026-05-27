#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Defaults
ADAPTER=""
SCOPE="repo"
COLLECTION=""
SKILL=""
TARGET=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Install agent skills from agentic-harness to your project.

Options:
  -a, --adapter <claude-code|codex>   Target agent platform (required, or auto-detect)
  -s, --scope <repo|user|admin>       Install scope (default: repo)
  -c, --collection <name>             Install a specific collection only
  -k, --skill <name>                  Install a specific skill only
  -t, --target <path>                 Target directory (default: current directory for repo scope)
  -h, --help                          Show this help

Scopes:
  repo    Install into the target project (default)
  user    Install into user-level config (~/.agents/skills or ~/.claude/skills)
  admin   Install into system-level config (codex only: /etc/codex/skills)

Examples:
  $(basename "$0") --adapter codex
  $(basename "$0") --adapter codex --scope user
  $(basename "$0") --adapter claude-code --skill clean-code
  $(basename "$0") --adapter codex --collection web-engineering --target ~/my-project
EOF
  exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--adapter)   ADAPTER="$2"; shift 2 ;;
    -s|--scope)     SCOPE="$2"; shift 2 ;;
    -c|--collection) COLLECTION="$2"; shift 2 ;;
    -k|--skill)     SKILL="$2"; shift 2 ;;
    -t|--target)    TARGET="$2"; shift 2 ;;
    -h|--help)      usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Auto-detect adapter if not specified
if [[ -z "$ADAPTER" ]]; then
  if [[ -d ".claude" ]] || [[ -f ".claude/settings.json" ]]; then
    ADAPTER="claude-code"
  elif [[ -d ".agents" ]] || [[ -f ".codex/config.toml" ]]; then
    ADAPTER="codex"
  else
    echo "Error: Cannot auto-detect adapter. Specify --adapter <claude-code|codex>" >&2
    exit 1
  fi
  echo "Auto-detected adapter: $ADAPTER"
fi

# Validate adapter
ADAPTER_SCRIPT="$SCRIPT_DIR/adapters/$ADAPTER/install.sh"
if [[ ! -f "$ADAPTER_SCRIPT" ]]; then
  echo "Error: Unknown adapter '$ADAPTER'. Available: claude-code, codex" >&2
  exit 1
fi

# Build arguments for adapter
ADAPTER_ARGS=("--skills-dir" "$SKILLS_DIR" "--scope" "$SCOPE")
[[ -n "$COLLECTION" ]] && ADAPTER_ARGS+=("--collection" "$COLLECTION")
[[ -n "$SKILL" ]] && ADAPTER_ARGS+=("--skill" "$SKILL")
[[ -n "$TARGET" ]] && ADAPTER_ARGS+=("--target" "$TARGET")

# Delegate to adapter
exec "$ADAPTER_SCRIPT" "${ADAPTER_ARGS[@]}"
