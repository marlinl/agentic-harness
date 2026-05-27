#!/usr/bin/env bash
set -euo pipefail

# Agentic Harness - Claude Code Adapter
# Installs skills into .claude/skills/ (repo) or ~/.claude/skills/ (user)

SKILLS_DIR=""
SCOPE="repo"
COLLECTION=""
SKILL_NAME=""
TARGET=""

usage() {
  cat <<EOF
Usage: $(basename "$0") --skills-dir <path> [OPTIONS]

Install skills for Claude Code.

Options:
  --skills-dir <path>       Path to agentic-harness skills/ directory (required)
  --scope <repo|user>       Install scope (default: repo)
  --collection <name>       Install a specific collection only
  --skill <name>            Install a specific skill only
  --target <path>           Target project directory for repo scope
  -h, --help                Show this help

Claude Code skill locations:
  repo   TARGET/.claude/skills/    (default: current directory)
  user   ~/.claude/skills/
EOF
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skills-dir)   SKILLS_DIR="$2"; shift 2 ;;
    --scope)        SCOPE="$2"; shift 2 ;;
    --collection)   COLLECTION="$2"; shift 2 ;;
    --skill)        SKILL_NAME="$2"; shift 2 ;;
    --target)       TARGET="$2"; shift 2 ;;
    -h|--help)      usage ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$SKILLS_DIR" ]]; then
  echo "Error: --skills-dir is required" >&2
  exit 1
fi

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

# Resolve target directory based on scope
resolve_target_dir() {
  case "$SCOPE" in
    repo)
      local base="${TARGET:-$(pwd)}"
      echo "$base/.claude/skills"
      ;;
    user)
      echo "$HOME/.claude/skills"
      ;;
    *)
      echo "Error: Unknown scope '$SCOPE' (supported: repo, user)" >&2
      exit 1
      ;;
  esac
}

TARGET_DIR="$(resolve_target_dir)"

# Find skill directories to install
find_skills() {
  local result=()

  if [[ -n "$SKILL_NAME" ]]; then
    local found=0
    for collection_dir in "$SKILLS_DIR"/*/; do
      [[ -d "$collection_dir" ]] || continue
      local skill_dir="$collection_dir$SKILL_NAME"
      if [[ -d "$skill_dir" ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
        result+=("$skill_dir")
        found=1
        break
      fi
    done
    if [[ $found -eq 0 ]]; then
      echo "Error: Skill '$SKILL_NAME' not found in any collection" >&2
      exit 1
    fi
  elif [[ -n "$COLLECTION" ]]; then
    local collection_dir="$SKILLS_DIR/$COLLECTION"
    if [[ ! -d "$collection_dir" ]]; then
      echo "Error: Collection '$COLLECTION' not found" >&2
      exit 1
    fi
    for skill_dir in "$collection_dir"/*/; do
      [[ -d "$skill_dir" ]] || continue
      if [[ -f "$skill_dir/SKILL.md" ]]; then
        result+=("$skill_dir")
      fi
    done
  else
    for collection_dir in "$SKILLS_DIR"/*/; do
      [[ -d "$collection_dir" ]] || continue
      for skill_dir in "$collection_dir"/*/; do
        [[ -d "$skill_dir" ]] || continue
        if [[ -f "$skill_dir/SKILL.md" ]]; then
          result+=("$skill_dir")
        fi
      done
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
echo "Installing skills for Claude Code..."
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
echo "Claude Code will auto-detect these skills."
