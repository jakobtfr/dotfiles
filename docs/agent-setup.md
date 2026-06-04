---
date: 2026-03-22
tags: [config, agents, workflow]
---

# Agent Setup

The canonical agent setup lives in `~/code/dotfiles/agent-coding/` and is read in
place -- it is `.chezmoiignore`d, so there is no deployed `~/agent-coding/` copy.

## Layout

| Runtime path | Source path | Purpose |
|---|---|---|
| `~/AGENTS.md` | `AGENTS.md` | Pointer only: `READ ~/code/dotfiles/agent-coding/AGENTS.md BEFORE ANYTHING` |
| `~/code/dotfiles/agent-coding/AGENTS.md` | `agent-coding/AGENTS.md` | Canonical shared/coding rules (read in place) |
| `~/code/dotfiles/agent-coding/work.md` | (untracked) | Amazon-internal rules; gitignored, auto-loaded on Claude via `~/.claude/rules/work.md` |
| `~/code/dotfiles/agent-coding/skills/` | `agent-coding/skills/` | Shared skill source |
| `~/.agents/skills` | `dot_agents/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native Codex skill discovery |
| `~/.claude/skills` | `dot_claude/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native Claude Code skill discovery |
| `~/.config/opencode/skills` | `dot_config/opencode/skills` | Symlink to `~/code/dotfiles/agent-coding/skills` for native OpenCode skill discovery |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex bootstrap, same pointer as `~/AGENTS.md` |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md.tmpl` | Claude Code bootstrap pointing to `~/code/dotfiles/agent-coding/AGENTS.md` |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config, rules bootstrap, and native skills |
| `~/.pi/agent/settings.json` | `dot_pi/agent/settings.json.tmpl` | Pi settings, including `~/.agents/skills` skill root |

## Rules

- Edit canonical rules and shared skills in `agent-coding/`.
- Keep `~/AGENTS.md` and downstream repo `AGENTS.md` files pointer-style.
- Keep provider-specific bootstrap/config in `dot_codex/`, `dot_claude/`, `dot_pi/`, and `dot_config/opencode/`.
- Run `ruby agent-coding/scripts/validate-skills` after skill edits.
- Deploy with `chezmoi apply` or `dotapply`; sync with `dotsync`.
