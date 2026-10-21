# dotfiles

Managed with [chezmoi](https://chezmoi.io); the source lives in `~/code/dotfiles`.

## New machine

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install chezmoi
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

## Daily

- `dotpull`: pull, apply, and `brew bundle` if the `Brewfile` changed
- `dotsync "msg"`: commit and push

## Layout

- `Brewfile`: packages and casks (casks are macOS only)
- `dot_*`: shell (zsh + p10k), nvim, tmux, herdr, ghostty, aerospace
- `.chezmoiscripts/`: `brew bundle` on Brewfile change; herdr agent hooks on herdr update

## Agents (Claude Code + Codex)

- Global rules: `dot_agents/AGENTS.md` → `~/.agents/AGENTS.md`; `~/.codex/AGENTS.md` symlinks to it,
  `~/.claude/CLAUDE.md` imports it.
- Repo rules: plain `AGENTS.md` in the repo (both agents read it natively).
- Skills: `dot_agents/skills/<name>/` → `~/.agents/skills` (Codex). For Claude, add
  `dot_claude/skills/symlink_<name>.tmpl` containing `{{ .chezmoi.homeDir }}/.agents/skills/<name>`.
- `create_*` files (`~/.claude/settings.json`, `~/.codex/config.toml`) are first-run seeds only;
  the apps own them afterwards.
