#!/usr/bin/env bash
set -euo pipefail

# Usage: ./install.sh [packages.txt]
# New-machine bootstrap: Homebrew packages/casks + chezmoi config/apply.

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
list_file="${1:-$script_dir/packages.txt}"
os="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$list_file" != /* ]]; then
  list_file="$PWD/$list_file"
fi

if [[ ! -f "$list_file" ]]; then
  echo "Error: $list_file not found" >&2
  exit 1
fi

load_brew_env() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return 0
  fi

  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done

  return 1
}

ensure_homebrew() {
  if load_brew_env; then
    return 0
  fi

  case "$os" in
    darwin|linux)
      echo "Installing Homebrew..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      ;;
    *)
      echo "Error: unsupported OS for automatic Homebrew install: $os" >&2
      exit 1
      ;;
  esac

  if ! load_brew_env; then
    echo "Error: Homebrew installed, but brew is still not on PATH" >&2
    exit 1
  fi
}

section_applies() {
  case "$1" in
    packages|casks)
      return 0
      ;;
    darwin|packages.darwin|casks.darwin)
      [[ "$os" == "darwin" ]]
      ;;
    linux|packages.linux)
      [[ "$os" == "linux" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

configure_chezmoi_source() {
  local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
  local config_file="${CHEZMOI_CONFIG_FILE:-$config_home/chezmoi/chezmoi.toml}"
  local escaped_source tmp_file

  mkdir -p "$(dirname -- "$config_file")"
  escaped_source="$(printf '%s' "$script_dir" | sed 's/\\/\\\\/g; s/"/\\"/g')"

  if [[ -f "$config_file" ]]; then
    tmp_file="$(mktemp)"
    awk -v source_line="sourceDir = \"$escaped_source\"" '
      NR == 1 { print source_line }
      /^[[:space:]]*sourceDir[[:space:]]*=/ { next }
      { print }
    ' "$config_file" > "$tmp_file"
    mv "$tmp_file" "$config_file"
  else
    printf 'sourceDir = "%s"\n' "$escaped_source" > "$config_file"
  fi
}

packages=()
casks=()
mode=""
mode_applies=false

while IFS= read -r line || [[ -n "$line" ]]; do
  # Trim spaces, skip empty or comments.
  line="$(echo "$line" | awk '{$1=$1};1')"
  [[ -z "$line" || "$line" == \#* ]] && continue

  if [[ "$line" == "["*"]" ]]; then
    mode="${line#[}"
    mode="${mode%]}"
    if section_applies "$mode"; then
      mode_applies=true
    else
      mode_applies=false
    fi
    continue
  fi

  [[ "$mode_applies" == true ]] || continue

  case "$mode" in
    casks|casks.darwin)
      casks+=("$line")
      ;;
    *)
      packages+=("$line")
      ;;
  esac
done < "$list_file"

ensure_homebrew

if (( ${#packages[@]} > 0 )); then
  echo "Installing Homebrew packages..."
  brew install "${packages[@]}"
fi

if (( ${#casks[@]} > 0 )); then
  if [[ "$os" == "darwin" ]]; then
    echo "Installing Homebrew casks..."
    brew install --cask "${casks[@]}"
  else
    echo "Skipping Homebrew casks on $os."
  fi
fi

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "Error: chezmoi is required before applying dotfiles" >&2
  exit 1
fi

echo "Configuring chezmoi source: $script_dir"
configure_chezmoi_source

echo "Applying dotfiles..."
chezmoi apply --source "$script_dir"

echo "Done. Restart your shell or run: exec zsh"
