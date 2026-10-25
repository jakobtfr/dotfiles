#!/usr/bin/env bash
# Ctrl-h/j/k/l pane navigation with Vim awareness, like vim-tmux-navigator:
# forward the key when Vim runs in the active pane, otherwise move focus.
set -euo pipefail

herdr=${HERDR_BIN_PATH:-herdr}
pane=${HERDR_ACTIVE_PANE_ID:?}

case $1 in
  left) key=ctrl+h ;;
  down) key=ctrl+j ;;
  up) key=ctrl+k ;;
  right) key=ctrl+l ;;
  *) exit 2 ;;
esac

if "$herdr" pane process-info --pane "$pane" |
  grep -qE '"name":"g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?"'; then
  "$herdr" pane send-keys "$pane" "$key" >/dev/null
else
  "$herdr" pane focus --pane "$pane" --direction "$1" >/dev/null
fi
