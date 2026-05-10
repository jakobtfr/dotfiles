# dotfiles

Policy and workflow: see `DOTFILES_POLICY.md`.
Full inventory: see `docs/dotfiles.md`.
Agent setup: see `docs/agent-setup.md`.

## New machine

```bash
mkdir -p ~/code
git clone https://github.com/jakobtfr/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

This installs Homebrew if needed, installs packages/casks from `packages.txt`, configures chezmoi to use this checkout as the source, applies dotfiles, and runs post-apply hooks for agent/Pi npm dependencies.

Daily usage: `dotapply`, `dotsync "chore(dotfiles): tweak shell"`, `dotpull`.

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
