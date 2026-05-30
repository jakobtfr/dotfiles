---
date: 2026-03-22
tags: [config, agents, workflow]
---

# Agent Setup

The canonical agent setup lives in `~/agent-coding/` (source:
`~/code/dotfiles/agent-coding/`).

## Layout

| Runtime path | Source path | Purpose |
|---|---|---|
| `~/AGENTS.md` | `AGENTS.md` | Pointer only: `READ ~/agent-coding/AGENTS.md BEFORE ANYTHING` |
| `~/agent-coding/AGENTS.md` | `agent-coding/AGENTS.md` | Canonical shared/coding rules |
| `~/agent-coding/skills/` | `agent-coding/skills/` | Shared skill source |
| `~/.agents/skills` | `dot_agents/skills` | Symlink to `~/agent-coding/skills` for native Codex skill discovery |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex bootstrap, same pointer as `~/AGENTS.md` |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md.tmpl` | Claude Code bootstrap pointing to `~/agent-coding/AGENTS.md` |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config and AGENTS bootstrap |
| `~/.pi/agent/settings.json` | `dot_pi/agent/settings.json.tmpl` | Pi settings, including `~/.agents/skills` skill root |

## Rules

- Edit canonical rules and shared skills in `agent-coding/`.
- Keep `~/AGENTS.md` and downstream repo `AGENTS.md` files pointer-style.
- Keep provider-specific bootstrap/config in `dot_codex/`, `dot_claude/`, `dot_pi/`, and `dot_config/opencode/`.
- Run `ruby agent-coding/scripts/validate-skills` after skill edits.
- Deploy with `chezmoi apply` or `dotapply`; sync with `dotsync`.
