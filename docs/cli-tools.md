---
date: 2026-03-22
tags: [config, tools, cli]
---

# CLI Tools (System-Wide)

Tools managed or referenced by the dotfiles setup.

| Tool | Install | Purpose |
|---|---|---|
| `chezmoi` | `brew install chezmoi` | Dotfile manager. Source: `~/code/dotfiles/`. |
| `tmuxp` | `pip install tmuxp` | tmux session manager. Configs at `~/.config/tmuxp/`. |
| `deepwiki-cli` | `brew tap hamsurang/deepwiki-cli && brew install deepwiki-cli` | Query public GitHub repos via DeepWiki. |
| `markitdown` | `uvx markitdown` (no install) | File-to-markdown conversion. Used in coding and notes. |

## tmuxp Sessions

| Session | Command | Windows |
|---|---|---|
| `dotfiles` | `tmuxp load dotfiles` | nvim on `~/code/dotfiles/` + opencode |
| `notes` | `tmuxp load notes` | nvim on `~/Documents/notes/` + opencode |
