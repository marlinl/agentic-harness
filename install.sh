#!/usr/bin/env bash
set -euo pipefail

# Agentic Harness — One-stop installer
#
# Scans ~/.claude and ~/.codex to detect installed tools,
# then installs skills for whichever ones exist.
#
# If the repo already exists at ~/.agentic-harness, checks for
# updates: if the remote commit differs, asks before overwriting.
#
# Usage:
#   ./install.sh                 # Auto-detect & install globally
#   ./install.sh --target DIR    # Install into a specific project
#   ./install.sh --uninstall     # Remove all symlinks

REPO_URL="https://github.com/marlinl/agentic-harness"
INSTALL_DIR="$HOME/.agentic-harness"
ACTION="install"
TARGET=""

# --- Parse args ---
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t) TARGET="$2"; shift 2 ;;
    --uninstall|-u) ACTION="uninstall"; shift ;;
    --help|-h)
      echo "Usage: $(basename "$0") [--target <dir>] [--uninstall]"
      echo ""
      echo "  --target DIR    Install into a specific project instead of globally"
      echo "  --uninstall     Remove all skill symlinks"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --- Helpers ---
ask_yes_no() {
  local prompt="$1"
  read -rp "$prompt [y/N] " answer
  [[ "$answer" =~ ^[Yy] ]]
}

skill_dirs() {
  local src="${1:-$INSTALL_DIR/skills}"
  for d in "$src"/*/; do
    [[ -d "$d" ]] && basename "$d"
  done
}

# --- Uninstall ---
do_uninstall() {
  echo "Agentic Harness — uninstalling"
  echo ""

  for skill_dir in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
    [[ -d "$skill_dir" ]] || continue
    for link in "$skill_dir"/*; do
      [[ -L "$link" ]] || continue
      target=$(readlink "$link")
      if [[ "$target" == "$INSTALL_DIR/"* ]]; then
        rm "$link"
        echo "  Removed $(basename "$link") from $skill_dir"
      fi
    done
  done

  echo ""
  echo "Symlinks removed. Repo still at $INSTALL_DIR"
  echo "To fully remove: rm -rf $INSTALL_DIR"
}

# --- Clone or update ---
clone_or_update() {
  if [[ ! -d "$INSTALL_DIR/.git" ]]; then
    echo "Cloning $REPO_URL ..."
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
    echo "Installed at $(git -C "$INSTALL_DIR" rev-parse --short HEAD)"
    return
  fi

  local old_commit new_commit
  old_commit=$(git -C "$INSTALL_DIR" rev-parse HEAD)
  git -C "$INSTALL_DIR" fetch --quiet origin 2>/dev/null || true
  new_commit=$(git -C "$INSTALL_DIR" rev-parse '@{u}' 2>/dev/null || echo "$old_commit")

  if [[ "$old_commit" == "$new_commit" ]]; then
    echo "Already up to date ($(git -C "$INSTALL_DIR" rev-parse --short HEAD))"
    return
  fi

  echo "Update available: $(git -C "$INSTALL_DIR" rev-parse --short "$old_commit") → $(git -C "$INSTALL_DIR" rev-parse --short "$new_commit")"
  if ask_yes_no "Overwrite?"; then
    git -C "$INSTALL_DIR" checkout --quiet "$new_commit"
    echo "Updated to $(git -C "$INSTALL_DIR" rev-parse --short HEAD)"
  else
    echo "Skipped update"
  fi
}

# --- Install skills into a directory ---
link_skills() {
  local dest="$1"
  local label="$2"
  local src="$INSTALL_DIR/skills"
  local count=0

  mkdir -p "$dest"

  for skill in $(skill_dirs "$src"); do
    local link="$dest/$skill"
    local target="$src/$skill"

    if [[ -L "$link" ]]; then
      local current
      current=$(readlink "$link")
      if [[ "$current" == "$target" ]]; then
        echo "  ✓ $skill"
        count=$((count + 1))
        continue
      fi
      echo "  ! $skill → $current (different target)"
      if ! ask_yes_no "    Overwrite?"; then
        continue
      fi
      rm "$link"
    elif [[ -e "$link" ]]; then
      echo "  - $skill (exists, not a symlink — skipped)"
      continue
    fi

    ln -s "$target" "$link"
    echo "  + $skill"
    count=$((count + 1))
  done

  if [[ "$count" -eq 0 ]]; then
    echo "  (no skills linked)"
  else
    echo "  $count skill(s) linked"
  fi
}

# --- Main ---
do_install() {
  # Project-level install via --target
  if [[ -n "$TARGET" ]]; then
    TARGET="$(cd "$TARGET" && pwd -P)"

    echo "Agentic Harness — project install"
    echo "  Target: $TARGET"
    echo ""

    clone_or_update
    echo ""

    link_skills "$TARGET/.agents/skills" "project"
    echo ""
    echo "Done. Skills available at $TARGET/.agents/skills/"
    return
  fi

  # Global install: detect tools
  local targets=()
  [[ -d "$HOME/.claude" ]] && targets+=("claude")
  [[ -d "$HOME/.codex" ]] && targets+=("codex")

  if [[ ${#targets[@]} -eq 0 ]]; then
    echo "Error: Neither ~/.claude nor ~/.codex found." >&2
    echo "Install Claude Code or Codex CLI first." >&2
    exit 1
  fi

  echo "Agentic Harness — global install"
  echo "Detected: ${targets[*]}"
  echo ""

  clone_or_update
  echo ""

  for t in "${targets[@]}"; do
    case "$t" in
      codex)
        echo "Codex CLI (~/.codex):"
        link_skills "$HOME/.agents/skills" "codex"
        echo ""
        ;;
      claude)
        echo "Claude Code (~/.claude):"
        link_skills "$HOME/.claude/skills" "claude"
        echo ""
        ;;
    esac
  done

  echo "Done! Installed $(skill_dirs | wc -l | tr -d ' ') skills."
}

case "$ACTION" in
  uninstall) do_uninstall ;;
  install)   do_install ;;
esac
