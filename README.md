# dotfiles

Managed with [chezmoi](https://chezmoi.io); the source lives in `~/code/dotfiles`.

## New machine

macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install chezmoi
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

Arch (no Homebrew; paru for repo + AUR packages):

```bash
sudo pacman -S --needed chezmoi git base-devel
git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin && (cd /tmp/paru-bin && makepkg -si)
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

## Daily

- `dotpull`: pull, apply, and install packages if `Brewfile` (macOS) or `packages-arch.txt` (Arch) changed
- `dotsync "msg"`: commit and push

## Layout

- `Brewfile`: macOS packages and casks
- `packages-arch.txt`: Arch packages (official repos + AUR, via paru)
- `.chezmoiexternal.toml.tmpl`: powerlevel10k on Linux (pinned upstream release)
- `dot_*`: shell (zsh + p10k), nvim, tmux, herdr, ghostty, aerospace (macOS), sway (Linux)
- `.chezmoiscripts/`: `brew bundle` / `paru -S --needed` on package-list change; on Linux, herdr and
  Claude Code via their official installers (once; they self-update); herdr agent hooks on herdr update

## Agents (Claude Code + Codex)

- Global rules: `dot_agents/AGENTS.md` → `~/.agents/AGENTS.md`; `~/.codex/AGENTS.md` symlinks to it,
  `~/.claude/CLAUDE.md` imports it.
- Repo rules: plain `AGENTS.md` in the repo (both agents read it natively).
- Skills: `dot_agents/skills/<name>/` → `~/.agents/skills` (Codex). For Claude, add
  `dot_claude/skills/symlink_<name>.tmpl` containing `{{ .chezmoi.homeDir }}/.agents/skills/<name>`.
- `create_*` files (`~/.claude/settings.json`, `~/.codex/config.toml`) are first-run seeds only;
  the apps own them afterwards.
- The shell's `codex` function uses API billing with the key in
  `~/wichtig/untitled folder/key`. It overrides the provider per invocation and keeps
  `~/.codex` shared with the subscription app (config, sessions, skills, and plugins).
  The key stays outside this repository. `codex login status` still reports the shared
  app login; the `cli_api` provider uses the key file for inference.
