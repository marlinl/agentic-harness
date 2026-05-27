#!/usr/bin/env bash
set -euo pipefail

# Agentic Harness - OpenAI Codex CLI Adapter
# Installs skills by copying to .agents/skills/ (repo), ~/.agents/skills/ (user), /etc/codex/skills/ (admin)

SKILLS_DIR=""
SCOPE="repo"
SKILL_NAME=""
TARGET=""

usage() {
  cat <<EOF
Usage: $(basename "$0") --skills-dir <path> [OPTIONS]

Install skills for OpenAI Codex CLI.

Options:
  --skills-dir <path>       Path to agentic-harness repo root (required)
  --scope <repo|user|admin> Install scope (default: repo)
  --skill <name>            Install a specific skill only
  --target <path>           Target project directory for repo scope
  -h, --help                Show this help

Codex skill locations:
  repo   TARGET/.agents/skills/    (default: current directory)
  user   ~/.agents/skills/
  admin  /etc/codex/skills/
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-dir) SKILLS_DIR="$2"; shift 2 ;;
    --scope)      SCOPE="$2"; shift 2 ;;
    --skill)      SKILL_NAME="$2"; shift 2 ;;
    --target)     TARGET="$2"; shift 2 ;;
    -h|--help)    usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$SKILLS_DIR" ]]; then
  echo "Error: --skills-dir is required" >&2
  exit 1
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: directory not found: $SKILLS_DIR" >&2
  exit 1
fi

# Resolve target directory based on scope
resolve_target_dir() {
  case "$SCOPE" in
    repo)
      local base="${TARGET:-$(pwd)}"
      echo "$base/.agents/skills"
      ;;
    user)
      echo "$HOME/.agents/skills"
      ;;
    admin)
      echo "/etc/codex/skills"
      ;;
    *)
      echo "Error: Unknown scope '$SCOPE'" >&2
      exit 1
      ;;
  esac
}

TARGET_DIR="$(resolve_target_dir)"

# Find skill directories to install.
# Skills are directories at the repo root containing SKILL.md.
# Directories starting with . are framework internals and skipped.
find_skills() {
  local result=()

  if [[ -n "$SKILL_NAME" ]]; then
    local skill_dir="$SKILLS_DIR/$SKILL_NAME"
    if [[ -d "$skill_dir" ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
      result+=("$skill_dir")
    else
      echo "Error: Skill '$SKILL_NAME' not found" >&2
      exit 1
    fi
  else
    for dir in "$SKILLS_DIR"/*/; do
      [[ -d "$dir" ]] || continue
      local name
      name="$(basename "$dir")"
      # Skip hidden dirs (framework internals like .harness)
      [[ "$name" == .* ]] && continue
      if [[ -f "$dir/SKILL.md" ]]; then
        result+=("$dir")
      fi
    done
  fi

  printf '%s\n' "${result[@]}"
}

# Install a single skill directory
install_skill() {
  local src="$1"
  local skill_name
  skill_name="$(basename "$src")"

  local dest="$TARGET_DIR/$skill_name"

  if [[ -e "$dest" ]] || [[ -L "$dest" ]]; then
    rm -rf "$dest"
  fi

  cp -r "$src" "$dest"

  echo "  Installed: $skill_name"
}

# Main
echo "Installing skills for Codex CLI..."
echo "  Scope: $SCOPE"
echo "  Target: $TARGET_DIR"
echo ""

mkdir -p "$TARGET_DIR"

skill_dirs="$(find_skills)"
count=0

while IFS= read -r dir; do
  [[ -n "$dir" ]] || continue
  install_skill "$dir"
  count=$((count + 1))
done <<< "$skill_dirs"

echo ""
echo "Done. Installed $count skill(s) to $TARGET_DIR"
echo ""
echo "Codex will auto-detect these skills on next start."
echo "If skills don't appear, restart Codex."
