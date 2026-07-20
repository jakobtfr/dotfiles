# Agent Coding

Coding-specific guardrails plus shared, agent-agnostic skills.

## Setup

Part of `~/code/dotfiles/`, but **read in place** -- not deployed by chezmoi (it is listed in `.chezmoiignore`). There is no `~/agent-coding/` copy; every reference points at this repo path directly.

- **Single source/runtime path:** `~/code/dotfiles/agent-coding/`
- **Shared skills:** `~/code/dotfiles/agent-coding/skills/`, symlinked as `~/.agents/skills`, `~/.claude/skills`, and `~/.config/opencode/skills`
- **Codex-native skills:** `dot_agents/skills` is a symlink source, deployed as `~/.agents/skills -> ~/code/dotfiles/agent-coding/skills`
- **Claude Code-native skills:** `dot_claude/skills` is a symlink source, deployed as `~/.claude/skills -> ~/code/dotfiles/agent-coding/skills`
- **OpenCode-native skills:** `dot_config/opencode/skills` is a symlink source, deployed as `~/.config/opencode/skills -> ~/code/dotfiles/agent-coding/skills`
- **Harness adapters:** Codex, Claude Code, and OpenCode discover symlinked shared skills natively; Pi points at the same root.
- **Local-only work rules:** `work.md` holds Amazon-internal rules; gitignored, never pushed. Auto-loaded on Claude via `~/.claude/rules/work.md`.
- **Pi extensions:** source `~/code/dotfiles/dot_pi/agent/extensions/`, deployed to `~/.pi/agent/extensions/`
- **Sync:** Edit here, then `dotsync` (skills npm deps reinstall via `run_after`).

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
- Prefer neutral env vars such as `AGENT_TMUX_SOCKET_DIR`, `AGENT_AUTH_DIR`, and `AGENT_SUMMARIZER_CMD`.
- Keep harness-specific config in adapter locations such as `dot_codex/`, `dot_claude/`, `dot_pi/`, and `dot_config/opencode/`.
- Keep compatibility fallbacks for existing local state when practical.

## Shared Skills

Shared skills live in `skills/` and are read from `~/code/dotfiles/agent-coding/skills/`.

- `commit/` -- commit workflow and Conventional Commit formatting.
- `create-cli/` -- CLI UX, flags, output contracts, and command trees.
- `github/` -- GitHub PRs, issues, CI, and `gh api` workflows.
- `github-deep-review/` -- deep issue/PR review: cause, provenance, best fix, proof, risk.
- `google-workspace/` -- Google Workspace API workflows across Gmail, Drive, Calendar, Docs, and Sheets.
- `librarian/` -- cache remote repos under `~/.cache/checkouts` for source inspection.
- `mermaid/` -- create and validate Mermaid diagrams.
- `review-loop/` -- run subagent `/review` until requested changes are resolved.
- `skill-cleaner/` -- audit skill budget, duplicates, usage, and stale skills.
- `summarize/` -- convert URLs/files to Markdown and optionally summarize.
- `tmux/` -- persistent, user-attachable terminals when native sessions are insufficient.
- `update-changelog/` -- update changelogs from release/tag history.
- `uv/` -- Python scripts, deps, and builds with `uv`.
- `web-browser/` -- `agent-browser` workflow plus local Chrome/CDP fallbacks.
