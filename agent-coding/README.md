# Agent Coding

Coding-specific guardrails plus shared, agent-agnostic skills.

## Setup

Managed by chezmoi as part of `~/code/dotfiles/`.

- **Source of truth:** `~/code/dotfiles/agent-coding/`
- **Deployed to:** `~/agent-coding/` via `chezmoi apply`
- **Shared skills:** source `~/code/dotfiles/agent-coding/skills/`, deployed to `~/agent-coding/skills/`
- **Harness adapters:** Codex, Pi, Claude Code, and OpenCode load this shared layer through thin per-tool config files.
- **Pi extensions:** source `~/code/dotfiles/dot_pi/agent/extensions/`, deployed to `~/.pi/agent/extensions/`
- **Sync:** Edit in chezmoi source, then `dotsync`

## Config Chain

1. **Global** `~/AGENTS.md` -- universal behavior and config routing
2. **Coding** `~/agent-coding/AGENTS.md` -- coding-specific workflow + skill triggers
3. **Repo-local** `<repo>/AGENTS.md` -- project-specific rules

Every coding repo's `AGENTS.md` should start with:

```md
READ ~/agent-coding/AGENTS.md BEFORE ANYTHING (skip if missing).
```

Which itself reads `~/AGENTS.md` first.

## Agent-neutral boundary

Shared files should stay provider-agnostic:

- Use `AGENTS.md` and `SKILL.md` for canonical behavior and workflows.
- Prefer neutral env vars such as `AGENT_TMUX_SOCKET_DIR`, `AGENT_AUTH_DIR`, and `AGENT_SUMMARIZER_CMD`.
- Keep harness-specific config in adapter locations such as `dot_codex/`, `dot_claude/`, `dot_pi/`, and `dot_config/opencode/`.
- Keep compatibility fallbacks for existing local state when practical.

## Shared Skills

Shared skills live in `skills/` and are usable by Codex, Pi, Claude Code, OpenCode, and other agents that read skill files.

- `commit/` -- commit workflow and Conventional Commit formatting.
- `create-cli/` -- CLI UX, flags, output contracts, and command trees.
- `frontend-design/` -- distinctive production frontend design.
- `github/` -- GitHub PRs, issues, CI, and `gh api` workflows.
- `github-deep-review/` -- deep issue/PR review: cause, provenance, best fix, proof, risk.
- `google-workspace/` -- Google Workspace API workflows across Gmail, Drive, Calendar, Docs, and Sheets.
- `librarian/` -- cache remote repos under `~/.cache/checkouts` for source inspection.
- `mermaid/` -- create and validate Mermaid diagrams.
- `skill-cleaner/` -- audit skill budget, duplicates, usage, and stale skills.
- `summarize/` -- convert URLs/files to Markdown and optionally summarize.
- `tmux/` -- private-socket workflow for background jobs, interactive CLIs, and debuggers.
- `update-changelog/` -- update changelogs from release/tag history.
- `uv/` -- Python scripts, deps, and builds with `uv`.
- `web-browser/` -- Chrome/CDP browser inspection, screenshots, and logs.

Notes-vault-specific skills stay in the notes `.agents/skills` directory.

## Upstream reference

`~/code/oss/agent-stuff/` is an upstream/reference clone only. Runtime config is owned in this dotfiles repo; copy/update selected skills or harness extensions intentionally.
