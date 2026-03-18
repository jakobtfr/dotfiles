#!/usr/bin/env bash

# Usage: ./install.sh [list.txt]
LIST_FILE="${1:-packages.txt}"

if [[ ! -f "$LIST_FILE" ]]; then
  echo "Error: $LIST_FILE not found"
  exit 1
fi

packages=()
casks=()
mode=""

while IFS= read -r line || [ -n "$line" ]; do
  # Trim spaces, skip empty or comments
  line=$(echo "$line" | awk '{$1=$1};1')
  [[ -z "$line" || "$line" == \#* ]] && continue

  if [[ "$line" == "[packages]" ]]; then
    mode="packages"
  elif [[ "$line" == "[casks]" ]]; then
    mode="casks"
  elif [[ "$mode" == "packages" ]]; then
    packages+=("$line")
  elif [[ "$mode" == "casks" ]]; then
    casks+=("$line")
  fi
done < "$LIST_FILE"

if (( ${#packages[@]} > 0 )); then
  echo "Installing packages..."
  brew install "${packages[@]}"
fi

if (( ${#casks[@]} > 0 )); then
  echo "Installing casks..."
  brew install --cask "${casks[@]}"
fi

echo "Done."