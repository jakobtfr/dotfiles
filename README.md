# dotfiles

Policy and workflow: see `DOTFILES_POLICY.md`.
Full inventory: see `docs/dotfiles.md`.
Agent setup: see `docs/agent-setup.md`.

Usage: `dotapply`, `dotsync "chore(dotfiles): tweak shell"`, `dotpull`.

## Managed by chezmoi

- Shell: `.zshrc`, `.p10k.zsh`, `.config/shell/{aliases,env}.zsh`
- Prompt: `.config/starship.toml`
- Editor: `.config/nvim/`
- Multiplexer: `.tmux.conf`, `.config/tmuxp/`
- Terminals: `.config/ghostty/`, `.config/wezterm/` (macOS only)
- Window manager: `.config/aerospace/` (macOS only)
- Agents:
  - Global: `~/AGENTS.md`, `~/agent-coding/` (rules + shared skills)
  - Codex: `~/.codex/AGENTS.md`
  - OpenCode: `~/.config/opencode/`
  - Pi: `~/.pi/agent/{settings.json,keybindings.json,extensions/,themes/}`
