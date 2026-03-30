# Global Agent Directives

Jakob owns this. Start: say hi + 1 motivating line.
Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Behavior
- Safety: never delete without asking. Use `trash` for deletes.
- Fix root cause (not band-aid).
- Unsure: read more code/context; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Leave breadcrumb notes in thread.
- New deps: quick health check (recent releases/commits, adoption).
- Web: search early; quote exact errors; prefer 2024–2026 sources.

## Git
- Safe by default: `git status/diff/log`. Push only when user asks.
- `git checkout` ok for PR review / explicit request.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit (`reset --hard`, `clean`, `restore`, `rm`, …).
- Don't delete/rename unexpected stuff; stop + ask.
- No repo-wide S/R scripts; keep edits small/reviewable.
- If user types a command ("pull and push"), that's consent for that command.
- No amend unless asked.
- Multi-agent: check `git status/diff` before edits; ship small commits.

## Global CLI Tools
- `trash` -- move files to Trash (`trash` on macOS, `trash-put` on Linux — aliased to `trash`)
- `markitdown` -- convert documents to markdown: `uvx markitdown file.pdf -o output.md`
- `deepwiki-cli` -- query public GitHub repos: `deepwiki-cli ask owner/repo "question"`
- `tmux` -- use only for persistence/interaction (debugger/server)
- `osascript -l JavaScript` -- Apple ecosystem (Reminders, Calendar) via JXA (macOS only)

## Domain-Specific Configs
- **Coding:** read `~/agent-coding/AGENTS.md` when working in `~/code/`.
- **Notes:** read the vault's `AGENTS.md` when working in `~/Documents/notes/`.

## Setup Map

Read this section when asked to modify the agent/dotfiles/notes configuration.

### Config Chain
```
~/AGENTS.md                              global (this file)
├── ~/agent-coding/AGENTS.md             coding-specific
│   └── <repo>/AGENTS.md                 project-specific
├── ~/Documents/notes/professional/AGENTS.md   career + uni vault
└── ~/Documents/notes/personal/AGENTS.md       learning + life vault
```

### Source of Truth: `~/code/dotfiles/` (chezmoi)
Everything below is managed here and deployed via `chezmoi apply`.

| File | Source path in dotfiles | Deployed to |
|---|---|---|
| Global agent config | `AGENTS.md` | `~/AGENTS.md` |
| Codex global bootstrap | `dot_codex/AGENTS.md.tmpl` | `~/.codex/AGENTS.md` |
| Coding agent config | `agent-coding/AGENTS.md` | `~/agent-coding/AGENTS.md` |
| Coding skills | `agent-coding/skills/` | `~/agent-coding/skills/` |
| Dotfiles docs | `docs/` | (not deployed, reference only) |
| Codex runtime state | `~/.codex/config.toml` | unmanaged; Codex writes trust/project state here |
| OpenCode config | `dot_config/opencode/opencode.json` | `~/.config/opencode/opencode.json` |
| tmuxp sessions | `dot_config/tmuxp/*.yaml` | `~/.config/tmuxp/*.yaml` |
| Shell aliases | `dot_config/shell/aliases.zsh.tmpl` | `~/.config/shell/aliases.zsh` |
| chezmoi data | `.chezmoidata.toml` | (chezmoi internal) |

### Notes Vault: `~/Documents/notes/` (git, obsidian-git sync)
Not managed by chezmoi. Separate git repo.

| File | Path |
|---|---|
| Professional vault config | `professional/AGENTS.md` |
| Personal vault config | `personal/AGENTS.md` |
| Shared skills | `skills/*.md` |
| Shared taste prefs | `.context/taste/preferences.md` |
| Professional context | `professional/.context/context/background.md` |
| Personal context | `personal/.context/context/background.md` |
| Email configs | `professional/.himalaya.toml`, `personal/.himalaya.toml` |
| Vault setup docs | `personal/config/` |

### Sync
- **Dotfiles + agent-coding:** `dotsync` (commits + pushes chezmoi source)
- **Notes vault:** obsidian-git plugin (auto-commit every 5 min)
