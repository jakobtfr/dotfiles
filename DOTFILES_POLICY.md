# Dotfiles Policy

## Source of truth
- Canonical source repo: `~/code/dotfiles`
- Verify anytime: `chezmoi source-path`

## Managed vs unmanaged
- Managed: reproducible config you want across machines.
- Never managed: secrets, machine-specific state, cache/log/session files, noisy generated files without reproducibility value.

## Command standard
- Managed existing file: `chezmoi edit <file>`
- Managed new file: `chezmoi add <file>`
- Unmanaged file: edit directly in `~/.config/...`

## Pre-commit habit
- `chezmoi status`
- `chezmoi diff`

## Noisy generated files policy
- No middle ground: every noisy file is explicitly tracked or explicitly ignored.
- Explicitly ignored now:
  - `~/.config/nvim/lazy-lock.json`
  - `~/.config/tmuxp/ipraktikum.yaml`
