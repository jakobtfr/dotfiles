# Agent Coding

Coding-specific agent guardrails and skills. Agent-agnostic -- works with any tool that reads `AGENTS.md`.

## Setup

Managed by chezmoi as part of `~/code/dotfiles/`.

- **Source of truth:** `~/code/dotfiles/agent-coding/`
- **Deployed to:** `~/agent-coding/` via `chezmoi apply`
- **Sync:** Edit in chezmoi source, then `dotsync`

## Config Chain

1. **Global** `~/AGENTS.md` -- universal rules (safety, git, global tools)
2. **Coding** `~/agent-coding/AGENTS.md` -- coding-specific (PRs, CI, commits, workspace)
3. **Repo-local** `<repo>/AGENTS.md` -- project-specific rules

Every coding repo's `AGENTS.md` starts with:
```
READ ~/agent-coding/AGENTS.md BEFORE ANYTHING (skip if missing).
```
Which itself reads `~/AGENTS.md` first.

## Skills

Reusable skill definitions in `skills/`:

- `create-cli/` -- CLI design (syntax, flags, output contracts)
- `frontend-design/` -- Frontend aesthetics (anti-AI-slop rules)
- `deepwiki/` -- Query public GitHub repos via DeepWiki CLI
