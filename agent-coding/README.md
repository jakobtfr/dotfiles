# Agent Coding

Coding-specific agent guardrails and curated skills.

## Setup

Managed by chezmoi as part of `~/code/dotfiles/`.

- **Source of truth:** `~/code/dotfiles/agent-coding/`
- **Deployed to:** `~/agent-coding/` via `chezmoi apply`
- **Pi skill discovery:** `dot_pi/agent/settings.json` points at `~/agent-coding/skills`
- **Pi extensions:** managed separately in `~/code/dotfiles/dot_pi/agent/extensions/`
- **Sync:** Edit in chezmoi source, then `dotsync`

## Config Chain

1. **Global** `~/AGENTS.md` -- universal rules (safety, git, global tools)
2. **Coding** `~/agent-coding/AGENTS.md` -- coding-specific workflow + skill triggers
3. **Repo-local** `<repo>/AGENTS.md` -- project-specific rules

Every coding repo's `AGENTS.md` starts with:

```md
READ ~/agent-coding/AGENTS.md BEFORE ANYTHING (skip if missing).
```

Which itself reads `~/AGENTS.md` first.

## Skills

Curated skill definitions in `skills/`:

- `commit/` -- commit workflow and Conventional Commit formatting.
- `frontend-design/` -- distinctive production frontend design.
- `github/` -- GitHub PRs, issues, CI, and `gh api` workflows.
- `librarian/` -- cache remote repos under `~/.cache/checkouts` for source inspection.
- `mermaid/` -- create and validate Mermaid diagrams.
- `native-web-search/` -- local web search with summaries and source URLs.
- `summarize/` -- convert URLs/files to Markdown and optionally summarize.
- `tmux/` -- safely drive background jobs, interactive CLIs, and debuggers via private tmux sockets.
- `update-changelog/` -- update changelogs from release/tag history.
- `uv/` -- Python scripts, deps, and builds with `uv`.
- `web-browser/` -- Chrome/CDP browser inspection, screenshots, and logs.

## Upstream reference

`~/code/oss/agent-stuff/` is an upstream/reference clone. Do not load it wholesale. Copy or update only selected coding skills into this directory. Copy selected Pi extensions into `dot_pi/agent/extensions/`.
