# Agent Scripts

Shared agent guardrails, skills, and helpers for coding projects. Agent-agnostic -- works with any tool that reads `AGENTS.md` (OpenCode, Gemini CLI, Claude Code, Codex, Cursor CLI).

## Managed by chezmoi

This directory is managed as part of `~/code/dotfiles/`. Source of truth: `~/code/dotfiles/code/agent-scripts/`. Deployed to `~/code/agent-scripts/` via `chezmoi apply`.

Edit in the chezmoi source, then `dotsync` to commit and push.

## Pointer-Style AGENTS

- Shared guardrail text lives here: `AGENTS.md`.
- Every consuming repo's `AGENTS.md` starts with `READ ~/code/agent-scripts/AGENTS.md BEFORE ANYTHING (skip if missing).` followed by repo-specific rules.
- Do not copy shared blocks into other repos. Downstream workspaces re-read this file at session start.

## Skills

Reusable skill definitions in `skills/`. Each skill has a `SKILL.md` with trigger, steps, and guidelines.

- `create-cli/` -- CLI design (syntax, flags, output contracts)
- `frontend-design/` -- Frontend aesthetics (anti-AI-slop rules)
- `markdown-converter/` -- File-to-markdown conversion via `markitdown`

## Docs Lister (`scripts/docs-list.ts`)

Walks `docs/`, enforces `summary` front-matter, surfaces `read_when` hints. Run: `bun scripts/docs-list.ts`.
