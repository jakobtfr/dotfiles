---
date: 2026-03-22
tags: [config, dotfiles, chezmoi]
---

# Dotfiles (chezmoi)

**Repo:** `~/code/dotfiles/` (git, pushed to GitHub)
**Manager:** chezmoi
**Sync:** `dotsync` commits + pushes. `dotpull` pulls + applies. `dotapply` diffs + applies.

## What's Managed

| Target | Source in dotfiles | Notes |
|---|---|---|
| `~/.zshrc` | `dot_zshrc.tmpl` | Templated (p10k, aliases) |
| `~/.p10k.zsh` | `dot_p10k.zsh` | Powerlevel10k config |
| `~/.config/ghostty/` | `dot_config/ghostty/` | Terminal emulator |
| `~/.config/nvim/` | `dot_config/nvim/` | Neovim config |
| `~/.config/starship.toml` | `dot_config/starship.toml` | Prompt |
| `~/.config/tmuxp/` | `dot_config/tmuxp/` | tmux session configs |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config + plugins |
| `~/.config/shell/` | `dot_config/shell/` | Shell aliases, env |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex global instruction bootstrap |
| `~/agent-coding/` | `agent-coding/` | Shared coding guardrails + skills |

`~/.codex/config.toml` is intentionally not managed here because Codex writes project trust and other runtime state into that file.

## Templating

chezmoi uses Go templates. Machine-specific overrides go in `~/.config/chezmoi/chezmoi.toml`.

Data variables (`.chezmoidata.toml`):
- `has_mise` -- whether mise is installed
- `has_brazil` -- whether brazil build system is present
- `email_personal` -- personal Gmail
- `email_professional` -- professional Gmail

## Key Commands

```bash
dotsync           # commit + push dotfiles
dotpull           # pull + chezmoi apply
dotapply          # diff + apply
chezmoi diff      # preview changes
chezmoi add FILE  # add a file to chezmoi management
```

## Neovim Plugins

Neovim plugins use the native `vim.pack` manager, so Neovim must be 0.12 or
newer. Plugin specs and setup live in `dot_config/nvim/lua/jakob/pack_init.lua`;
the native lockfile is managed at `dot_config/nvim/nvim-pack-lock.json`.

Inside Neovim:

```vim
:lua vim.pack.update()
```
