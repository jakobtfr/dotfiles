#!/usr/bin/env bash
set -euo pipefail

install_if_needed() {
  local dir="$1"
  local label="$2"

  if [[ ! -f "$dir/package-lock.json" ]]; then
    return 0
  fi

  if [[ ! -d "$dir/node_modules" || "$dir/package-lock.json" -nt "$dir/node_modules/.package-lock.json" ]]; then
    echo "Installing $label dependencies..."
    npm ci --prefix "$dir"
  fi
}

case "$(hostname)" in
  50f265e89d43)
    ;;
  *)
    install_if_needed "$HOME/code/dotfiles/agent-coding/skills/web-browser/scripts" "agent-coding web-browser skill"
    install_if_needed "$HOME/code/dotfiles/agent-coding/skills/google-workspace" "agent-coding google-workspace skill"
    ;;
esac
