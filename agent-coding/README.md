# Agent Scripts

Shared agent guardrails, skills, and helpers for **coding projects**. Agent-agnostic -- works with any tool that reads `AGENTS.md` (OpenCode, Gemini CLI, Claude Code, Codex, Cursor CLI).

## Setup

This directory is managed by chezmoi as part of `~/code/dotfiles/`.

- **Source of truth:** `~/code/dotfiles/agent-coding/`
- **Deployed to:** `~/agent-coding/` via `chezmoi apply`
- **Sync:** Edit in chezmoi source, then `dotsync`

## How It Works

### Pointer-Style AGENTS

Every coding repo's `AGENTS.md` starts with:
```
READ ~/agent-coding/AGENTS.md BEFORE ANYTHING (skip if missing).
```
Followed by repo-specific rules. The shared guardrails are never duplicated -- downstream repos reference this file at session start.

### Coding Skills

Reusable skill definitions in `skills/`. Each skill has a `SKILL.md` with trigger, steps, and guidelines.

- `create-cli/` -- CLI design (syntax, flags, output contracts)
- `frontend-design/` -- Frontend aesthetics (anti-AI-slop rules)
- `markdown-converter/` -- File-to-markdown conversion via `markitdown`

### Docs

Reference docs in `docs/` with `summary` front-matter for agent context.

## Scope: Coding Only

This repo governs **coding projects only**. It has no overlap with the Obsidian notes vault.

The notes vault (`~/Documents/notes/`) has its own separate system:
- Its own `AGENTS.md` per vault (personal / professional)
- Its own shared `skills/` (email, anki, PDF processing, inbox)
- Its own `.context/` directories (taste, background)

The two systems are intentionally isolated. An agent in a coding project reads agent-coding. An agent in the notes vault reads the vault's AGENTS.md. They never cross.
