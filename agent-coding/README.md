# Agent Coding

Coding-specific guardrails plus shared, agent-agnostic skills.

## Setup

Part of `~/code/dotfiles/`, but **read in place** -- not deployed by chezmoi (it is listed in `.chezmoiignore`). There is no `~/agent-coding/` copy; every reference points at this repo path directly.

- **Single source/runtime path:** `~/code/dotfiles/agent-coding/`
- **Shared skills:** `~/code/dotfiles/agent-coding/skills/`, symlinked as `~/.agents/skills`, `~/.claude/skills`, and `~/.config/opencode/skills`
- **Codex-native skills:** `dot_agents/symlink_skills.tmpl` deploys `~/.agents/skills -> ~/code/dotfiles/agent-coding/skills`
- **Claude Code-native skills:** `dot_claude/symlink_skills.tmpl` deploys `~/.claude/skills -> ~/code/dotfiles/agent-coding/skills`
- **OpenCode-native skills:** `dot_config/opencode/symlink_skills.tmpl` deploys `~/.config/opencode/skills -> ~/code/dotfiles/agent-coding/skills`
- **Harness adapters:** Codex, Claude Code, OpenCode, and Pi discover the shared skills through their native skill paths.
- **Sync:** Edit here, then `dotsync`.

## Vanilla-first boundary

- Keep harness defaults unless a small adapter is required to share rules or skills.
- Pi has no managed settings, models, modes, keybindings, themes, extensions, packages, or MCP configuration.
- Codex optional plugins are not part of this repository and remain disabled locally.

## Config Chain

1. **Global** `~/AGENTS.md` -- pointer to `~/code/dotfiles/agent-coding/AGENTS.md`
2. **Coding** `~/code/dotfiles/agent-coding/AGENTS.md` -- canonical shared hard rules + coding workflow
3. **Repo-local** `<repo>/AGENTS.md` -- project-specific rules
4. **Shared skills** native symlinks under `~/.agents/skills/`, `~/.claude/skills/`, and `~/.config/opencode/skills/`

Root and downstream repo `AGENTS.md` files should be pointer-style:

```md
READ ~/code/dotfiles/agent-coding/AGENTS.md BEFORE ANYTHING (skip if missing).
```

Repo-specific rules go below that pointer.

## Agent-neutral boundary

Shared files should stay provider-agnostic:

- Use `AGENTS.md` and `SKILL.md` for canonical behavior and workflows.
- Prefer neutral env vars such as `AGENT_TMUX_SOCKET_DIR`.
- Keep unavoidable harness-specific config in adapter locations such as `dot_codex/`, `dot_claude/`, and `dot_config/opencode/`.
- Keep compatibility fallbacks for existing local state when practical.

## Shared Skills

Shared skills live in `skills/` and are read from `~/code/dotfiles/agent-coding/skills/`.

- `commit/` -- commit workflow and Conventional Commit formatting.
- `github-deep-review/` -- deep issue/PR review: cause, provenance, best fix, proof, risk.
- `librarian/` -- cache remote repos under `~/.cache/checkouts` for source inspection.
- `review-fix/` -- run one subagent `/review` and resolve requested changes.
- `skill-cleaner/` -- audit skill budget, duplicates, usage, and stale skills.
- `summarize/` -- convert URLs/files to Markdown and optionally summarize.
- `tmux/` -- persistent, user-attachable terminals when native sessions are insufficient.
- `uv/` -- Python scripts, deps, and builds with `uv`.
- `agent-browser/` -- official Vercel Labs discovery skill; loads version-matched guidance from the installed CLI.
