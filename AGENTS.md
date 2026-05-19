# Global Agent Directives

Jakob owns this. Start: say hi + 1 motivating line.
Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Behavior
- Safety: never delete without asking. Use `trash` for deletes.
- Fix root cause (not band-aid).
- Agent config discovery: never recurse into dependency/generated dirs when searching for `AGENTS.md`; prune `node_modules`, `.git`, `.venv`, `dist`, `build`, caches.
- Unsure: read more code/context; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Leave breadcrumb notes in thread.
- New deps: quick health check (recent releases/commits, adoption).
- Web: search early with available search skill/tool; quote exact errors; prefer 2024–2026 sources.

## Git Safety
- Safe by default: inspect `git status`/`diff`/`log` before git actions.
- Push, amend, branch changes, and destructive ops require explicit consent.
- Destructive ops include `reset --hard`, `clean`, `restore`, `rm`, and force push.
- Don't touch unexpected untracked/modified files; stop + ask.
- If user types a command ("pull", "push"), that's consent for that command only.

## Context Routing
- **Coding:** read `~/agent-coding/AGENTS.md` when working in `~/code/`.
- **Notes:** read the vault's `AGENTS.md` when working in the notes vault.
- **Skills:** use `~/agent-coding/skills/<name>/SKILL.md` when relevant.

## Global CLI Tools
- `trash` -- move files to Trash (`trash` on macOS, `trash-put` on Linux — aliased to `trash`).
- `osascript -l JavaScript` -- Apple ecosystem automation via JXA (macOS only).

## Setup Map

Read this section when asked to modify the agent/dotfiles/notes configuration.

### Config Chain
```
~/AGENTS.md                              global behavior + routing
├── ~/agent-coding/AGENTS.md             coding-specific
│   ├── ~/agent-coding/skills/           shared agent-agnostic skills
│   └── <repo>/AGENTS.md                 project-specific
└── <notes-vault>/.../AGENTS.md          notes-specific
```

### Source of Truth: `~/code/dotfiles/` (chezmoi)
Managed via `chezmoi apply`. Tables below are scoped to agents + shell;
for the full inventory (terminals, editor, WM, prompt, etc.) see
`~/code/dotfiles/docs/dotfiles.md`.

**Agent config**

| File | Source path in dotfiles | Deployed to |
|---|---|---|
| Global agent config | `AGENTS.md` | `~/AGENTS.md` |
| Coding agent config | `agent-coding/AGENTS.md` | `~/agent-coding/AGENTS.md` |
| Shared skills | `agent-coding/skills/` | `~/agent-coding/skills/` |
| Pi settings | `dot_pi/agent/settings.json.tmpl` | `~/.pi/agent/settings.json` |
| Pi keybindings | `dot_pi/agent/keybindings.json` | `~/.pi/agent/keybindings.json` |
| Pi extensions | `dot_pi/agent/extensions/` | `~/.pi/agent/extensions/` |
| Pi themes | `dot_pi/agent/themes/` | `~/.pi/agent/themes/` |
| Codex global bootstrap | `dot_codex/AGENTS.md.tmpl` | `~/.codex/AGENTS.md` |
| OpenCode global bootstrap | `dot_config/opencode/AGENTS.md.tmpl` | `~/.config/opencode/AGENTS.md` |
| OpenCode config | `dot_config/opencode/opencode.json` | `~/.config/opencode/opencode.json` |

**Shell + multiplexer**

| File | Source path in dotfiles | Deployed to |
|---|---|---|
| zsh config | `dot_zshrc.tmpl` | `~/.zshrc` |
| Powerlevel10k | `dot_p10k.zsh` | `~/.p10k.zsh` |
| Shell aliases | `dot_config/shell/aliases.zsh.tmpl` | `~/.config/shell/aliases.zsh` |
| Shell env | `dot_config/shell/env.zsh.tmpl` | `~/.config/shell/env.zsh` |
| tmux config | `dot_tmux.conf` | `~/.tmux.conf` |
| tmuxp sessions | `dot_config/tmuxp/*.yaml` | `~/.config/tmuxp/*.yaml` |
| chezmoi data | `.chezmoidata.toml` | (chezmoi internal) |

### Notes Vault
The notes vault is not managed by chezmoi. It has separate git/Obsidian sync and its own `.agents/skills` for notes/email/calendar workflows.

Current vault path:
`/Users/jakobfriedrich/Library/Mobile Documents/iCloud~md~obsidian/Documents/notes/`

### Sync
- **Dotfiles + agent-coding + shared skills:** `dotsync` (commits + pushes chezmoi source)
- **Notes vault:** obsidian-git plugin (auto-commit every 5 min)
