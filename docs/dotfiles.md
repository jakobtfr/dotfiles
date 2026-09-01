---
date: 2026-09-01
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
| `~/.config/herdr/` | `dot_config/herdr/` | Herdr config with tmux-style keybindings |

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
| `~/.agents/skills` | `dot_agents/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.claude/skills` | `dot_claude/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.config/opencode/skills` | `dot_config/opencode/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native skill discovery |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex global instruction bootstrap |
| `~/.codex/bedrock-models.json` | `dot_codex/bedrock-models.json` | Bedrock model catalog with the 1M context default |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md.tmpl` | Claude Code instruction bootstrap |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config + rules bootstrap + native skills |

`~/.codex/config.toml` is not continuously managed because Codex writes project trust and other runtime state into that file. Chezmoi seeds it once with stable defaults, including the Bedrock model catalog path. `~/.codex/azure.config.toml` is also create-once: chezmoi seeds the Azure profile on new machines, then leaves local Codex trust/project edits alone. Optional Codex plugins are not managed and remain disabled locally.

Pi is installed through `packages.txt` but otherwise left vanilla. Its settings,
credentials, sessions, models, keybindings, extensions, themes, packages, and MCP
configuration are app-owned and absent from the dotfiles source.

Repo-meta files (`README.md`, `docs/`, `install.sh`, `packages.txt`) are excluded from deployment via `.chezmoiignore` and stay in `~/code/dotfiles/` only.

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
setup files from `dot_config/nvim/lua/jakob/plugins/`. The generated
`~/.config/nvim/nvim-pack-lock.json` stays machine-local and is ignored by
chezmoi.

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
