# Agent Coding

Coding-specific agent guardrails, curated skills, and curated Pi extensions.

## Setup

Managed by chezmoi as part of `~/code/dotfiles/`.

- **Source of truth:** `~/code/dotfiles/agent-coding/`
- **Deployed to:** `~/agent-coding/` via `chezmoi apply`
- **Pi discovery:** `dot_pi/agent/settings.json` points at `~/agent-coding/skills` and `~/agent-coding/extensions`
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
- `tmux/` -- safely drive interactive CLIs/debuggers via private tmux sockets.
- `update-changelog/` -- update changelogs from release/tag history.
- `uv/` -- Python scripts, deps, and builds with `uv`.
- `web-browser/` -- Chrome/CDP browser inspection, screenshots, and logs.

## Pi Extensions

Curated Pi extensions in `extensions/`:

- `answer.ts` -- `/answer` Q&A flow for assistant questions (`ctrl+.`).
- `btw.ts` -- `/btw` side-chat popover with optional summary injection.
- `control.ts` -- session-control commands/tools for controllable Pi sessions.
- `files.ts` -- `/files` file browser, reveal/open/edit/diff actions, shortcuts.
- `loop.ts` -- `/loop` auto-follow-up loop plus `signal_loop_success` tool.
- `notify.ts` -- terminal desktop notification on agent completion.
- `prompt-editor.ts` -- `/mode` prompt modes, custom editor, model/tool/thinking presets.
- `review.ts` -- `/review` and `/end-review` code review workflow.
- `session-breakdown.ts` -- `/session-breakdown` usage/session/cost analytics.
- `split-fork.ts` -- `/split-fork` into a Ghostty split.
- `todos.ts` -- `/todos` UI and `todo` tool backed by `.pi/todos`.

Skipped upstream extensions: `go-to-bed.ts`, `multi-edit.ts`, `uv.ts`, `whimsical.ts`.

## Upstream reference

`~/code/oss/agent-stuff/` is an upstream/reference clone. Do not load it wholesale. Copy or update only selected skills/extensions into this directory.
