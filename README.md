# dotfiles

My config files, managed with [chezmoi](https://chezmoi.io). They live in `~/code/dotfiles`.

## Set up a new machine

macOS:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
/opt/homebrew/bin/brew install chezmoi
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

Arch:

```bash
sudo pacman -S --needed chezmoi git base-devel
git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin && (cd /tmp/paru-bin && makepkg -si)
chezmoi init --apply --source ~/code/dotfiles jakobtfr/dotfiles
```

This copies the config files into place and installs every program they need. Claude Code and herdr
are installed by hand.

## Everyday use

- `dotpull`: get the latest changes and apply them
- `dotsync "message"`: save and upload my changes

## Programs

To add a program, put it in `Brewfile` (macOS) or `packages-arch.txt` (Arch) and run `dotpull`.

Some installers add lines to `~/.zshrc`. `chezmoi diff` shows those edits, and the next `dotpull`
offers to overwrite them. If a line is needed, move it to `dot_config/shell/env.zsh.tmpl` in this
repo, or to `~/.config/shell/local.zsh` if it only applies to one machine. That file isn't tracked.
