# Agent Directives: Coding

READ ~/AGENTS.md BEFORE ANYTHING (skip if missing).

Coding-specific rules for projects in `~/code/`.

## Workspace
- `~/code/projects` -- own repos. Missing jakobtfr repo: clone `https://github.com/jakobtfr/<repo>.git`.
- `~/code/other` -- 3rd-party/OSS (non-jakobtfr).
- Editor: `nvim <path>`.
- Keep files <~500 LOC; split/refactor as needed.

## Commits & PRs
- Before committing, read the `commit` skill.
- For GitHub/PR/CI work, read the `github` skill; use `gh`, not browser URLs.
- Replies: cite fix + file/line; resolve threads only after fix lands.

## Build / Test / CI
- Before handoff: run full gate (lint/typecheck/tests/docs).
- CI red: `gh run list/view`, rerun, fix, push, repeat til green.
- Keep it observable (logs, panes, tails, MCP/browser tools).
- Use repo's package manager/runtime; no swaps w/o approval.
- Short checks: run directly. Long-running jobs, dev servers, watchers, REPLs, and debuggers: read the `tmux` skill; run detached on a private socket; print attach/capture commands; poll output; clean up when done.

## Docs
- Open docs before coding.
- Follow links until domain makes sense; honor `Read when` hints.
- Keep notes short; update docs when behavior/API changes (no ship w/o docs).

## Language/Stack Notes
- TypeScript: use repo PM; keep files small; follow existing patterns.

## Skills
Shared skills live in `~/agent-coding/skills/`. Read `~/agent-coding/skills/<name>/SKILL.md` when relevant.
- `commit` -- before committing.
- `frontend-design` -- before creating/restyling UI.
- `github` -- GitHub/PR/CI work.
- `google-workspace` -- Google Workspace tasks across Gmail, Drive, Calendar, Docs, Sheets.
- `librarian` -- referenced remote repos; use cached checkouts under `~/.cache/checkouts` instead of ad hoc clones.
- `mermaid` -- before creating/editing Mermaid diagrams.
- `native-web-search` -- web research with source URLs.
- `summarize` -- convert URLs/docs/PDFs to Markdown.
- `tmux` -- before background jobs or interactive CLIs/debuggers.
- `update-changelog` -- before changelog edits.
- `uv` -- before Python deps/scripts/builds.
- `web-browser` -- live browser/UI inspection.
