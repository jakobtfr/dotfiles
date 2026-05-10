#!/usr/bin/env bash
set -euo pipefail

# Usage: ./install.sh [list.txt]
# Installs Homebrew packages/casks, then applies this chezmoi source tree.

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
list_file="${1:-$script_dir/packages.txt}"

if [[ "$list_file" != /* ]]; then
  list_file="$PWD/$list_file"
fi

if [[ ! -f "$list_file" ]]; then
  echo "Error: $list_file not found" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is required before running this installer" >&2
  exit 1
fi

packages=()
casks=()
mode=""

while IFS= read -r line || [[ -n "$line" ]]; do
  # Trim spaces, skip empty or comments.
  line="$(echo "$line" | awk '{$1=$1};1')"
  [[ -z "$line" || "$line" == \#* ]] && continue

  case "$line" in
    "[packages]")
      mode="packages"
      ;;
    "[casks]")
      mode="casks"
      ;;
    "["*"]")
      mode=""
      ;;
    *)
      case "$mode" in
        packages) packages+=("$line") ;;
        casks) casks+=("$line") ;;
      esac
      ;;
  esac
done < "$list_file"

if (( ${#packages[@]} > 0 )); then
  echo "Installing packages..."
  brew install "${packages[@]}"
fi

if (( ${#casks[@]} > 0 )); then
  echo "Installing casks..."
  brew install --cask "${casks[@]}"
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Error: chezmoi is required before applying dotfiles" >&2
  exit 1
fi

echo "Applying dotfiles..."
chezmoi apply --source "$script_dir"

echo "Done."
