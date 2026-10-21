---
date: 2026-09-01
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
| `~/code/dotfiles/agent-coding/skills/` | `agent-coding/skills/` | Shared skill source |
| `~/.agents/skills` | `dot_agents/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native Codex skill discovery |
| `~/.claude/skills` | `dot_claude/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native Claude Code skill discovery |
| `~/.config/opencode/skills` | `dot_config/opencode/symlink_skills.tmpl` | Symlink to `~/code/dotfiles/agent-coding/skills` for native OpenCode skill discovery |
| `~/.codex/AGENTS.md` | `dot_codex/AGENTS.md.tmpl` | Codex bootstrap, same pointer as `~/AGENTS.md` |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md.tmpl` | Claude Code bootstrap pointing to `~/code/dotfiles/agent-coding/AGENTS.md` |
| `~/.claude/settings.json` | `dot_claude/create_settings.json` | Create-once seed: default model Opus 5.5, high effort |
| `~/.config/opencode/` | `dot_config/opencode/` | OpenCode config, rules bootstrap, and native skills |

Pi is intentionally unmanaged beyond installing the CLI. Its native defaults own
settings and runtime state; there are no custom Pi extensions, themes, models,
keybindings, packages, or MCP servers in this repository. Pi can discover the
shared `~/.agents/skills` path without a Pi-specific adapter.

Codex uses only its bootstrap, model profiles, and shared native skills. Optional
Codex plugins are disabled and are not configured by these dotfiles.

## Rules

- Edit canonical rules and shared skills in `agent-coding/`.
- Keep `~/AGENTS.md` and downstream repo `AGENTS.md` files pointer-style.
- Prefer native defaults; add provider-specific bootstrap/config only when required.
- Keep unavoidable adapters in `dot_codex/`, `dot_claude/`, and `dot_config/opencode/`.
- Run `ruby agent-coding/scripts/validate-skills` after skill edits.
- Deploy with `chezmoi apply` or `dotapply`; sync with `dotsync`.
