---
date: 2026-03-22
tags: [config, dotfiles, chezmoi]
---

# Dotfiles (chezmoi)

**Repo:** `~/code/dotfiles/` (git, pushed to GitHub)
**Manager:** chezmoi
**Sync:** `dotsync` commits + pushes. `dotpull` pulls + applies. `dotapply` diffs + applies.

## What's Managed

### Shell + prompt

| Target | Source in dotfiles | Notes |
|---|---|---|
| `~/.zshrc` | `dot_zshrc.tmpl` | Templated (mise, brew, sources `~/.config/shell/`) |
| `~/.p10k.zsh` | `dot_p10k.zsh` | Powerlevel10k config |
| `~/.config/starship.toml` | `dot_config/starship.toml` | Prompt (alternate) |
| `~/.config/shell/aliases.zsh` | `dot_config/shell/aliases.zsh.tmpl` | Shell aliases |
| `~/.config/shell/env.zsh` | `dot_config/shell/env.zsh.tmpl` | Shell env vars |

### Editor + multiplexer

| Target | Source in dotfiles | Notes |
|---|---|---|
| `~/.config/nvim/` | `dot_config/nvim/` | Neovim config (uses `vim.pack`) |
| `~/.tmux.conf` | `dot_tmux.conf` | tmux config |
| `~/.config/tmuxp/` | `dot_config/tmuxp/` | tmux session configs |

### Terminal + window manager (macOS-only)

| Target | Source in dotfiles | Notes |
|---|---|---|
| `~/.config/ghostty/` | `dot_config/ghostty/` | Terminal emulator |
| `~/.config/wezterm/` | `dot_config/wezterm/` | Terminal emulator (alt) |
| `~/.config/aerospace/` | `dot_config/aerospace/` | Tiling window manager |

Gated off on non-darwin via `.chezmoiignore`.

### Agents

| Target | Source in dotfiles | Notes |
|---|---|---|
| `~/AGENTS.md` | `AGENTS.md` | Pointer to `~/code/dotfiles/agent-coding/AGENTS.md` |
| `~/code/dotfiles/agent-coding/` | `agent-coding/` | Canonical shared/coding rules, scripts, and skills (read in place; `.chezmoiignore`d, not deployed) |
| `~/.agents/skills` | `dot_agents/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.claude/skills` | `dot_claude/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.config/opencode/skills` | `dot_config/opencode/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex global instruction bootstrap |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md.tmpl` | Claude Code instruction bootstrap |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config + rules bootstrap + native skills |
| `~/.pi/agent/settings.json` | `dot_pi/agent/settings.json.tmpl` | Pi settings |
| `~/.pi/agent/keybindings.json` | `dot_pi/agent/keybindings.json` | Pi keybindings |
| `~/.pi/agent/extensions/` | `dot_pi/agent/extensions/` | Pi extensions (TS) |
| `~/.pi/agent/themes/` | `dot_pi/agent/themes/` | Pi themes |

`~/.codex/config.toml` is intentionally not managed here because Codex writes project trust and other runtime state into that file. `~/.pi/agent/auth.json` and `~/.pi/agent/sessions/` are explicitly ignored (runtime state). Repo-meta files (`README.md`, `DOTFILES_POLICY.md`, `docs/`, `install.sh`, `packages.txt`) are excluded from deployment via `.chezmoiignore` and stay in `~/code/dotfiles/` only.

## Templating

chezmoi uses Go templates. Machine-specific overrides go in `~/.config/chezmoi/chezmoi.toml`.

Data variables (`.chezmoidata.toml`):
- `has_mise` -- whether mise is installed
- `has_brazil` -- whether brazil build system is present
- `email_personal` -- personal Gmail
- `email_professional` -- professional Gmail

## Key Commands

```bash
./install.sh      # new-machine bootstrap: Homebrew + packages/casks + chezmoi config/apply
dotsync           # commit + push dotfiles
dotpull           # pull + chezmoi apply
dotapply          # diff + apply
chezmoi diff      # preview changes
chezmoi add FILE  # add a file to chezmoi management
```

## Neovim Plugins

Neovim plugins use the native `vim.pack` manager, so Neovim must be 0.12 or
newer. `dot_config/nvim/lua/jakob/pack_init.lua` loads the per-plugin specs and
setup files from `dot_config/nvim/lua/jakob/plugins/`; the native lockfile is
managed at `dot_config/nvim/nvim-pack-lock.json`.

Inside Neovim:

```vim
:lua vim.pack.update()
```

Or use the local alias:

```vim
:PackUpdate
```

LSP uses Neovim's native `vim.lsp.config()` / `vim.lsp.enable()` flow.
`nvim-lspconfig` is kept for server config data, but no language servers are
enabled by default; add servers to `dot_config/nvim/lua/jakob/lsp.lua` as they
are needed.
