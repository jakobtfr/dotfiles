# Agent Directives: Coding

READ ~/AGENTS.md BEFORE ANYTHING (skip if missing).

Coding-specific rules for projects in `~/code/`.

## Core

- Workspace: `~/code/projects` for own repos; `~/code/other` for 3rd-party/OSS. Missing jakobtfr repo: clone `https://github.com/jakobtfr/<repo>.git`.
- Shared skills live in `~/agent-coding/skills/`. Read `~/agent-coding/skills/<name>/SKILL.md` when relevant.
- Skills are canonical for tool workflows. Keep this file to coding hard rules and skill routing.

## Project Defaults

- Use repo package manager/runtime; no swaps without approval.
- TypeScript: use repo PM; keep files cohesive; follow existing patterns.
- Bugs: add regression test when it fits.
- Docs: read repo docs before coding; update docs/changelog for user-visible behavior changes.
- Inline code comments: brief notes for tricky, bug-prone, or previously buggy logic.
- Prefer small cohesive files; split/refactor when size hides structure.

## Build / Test / CI

- Before handoff: run the narrowest meaningful gate. Run full lint/typecheck/tests/docs for broad or risky changes, or before commit/PR when practical.
- Keep work observable: logs, panes, tails, MCP/browser tools.
- Short checks: run directly.
- Long-running jobs, dev servers, watchers, REPLs, and debuggers: read `tmux`; run detached on a private socket; print attach/capture commands; poll output; clean up when done.
- CI red: use `gh run list/view`; fix locally. Rerun/push only when requested or already covered by user intent.

## PR / CI

- Before committing: read `commit`.
- GitHub/PR/CI work: read `github`; use `gh`, not browser URLs.
- PR refs: use `gh pr view/diff`, not web search.
- Replies: cite fix + file/line; resolve threads only after fix lands.
- User-facing fixes/landed PRs: update changelog unless pure test/internal.

## Skills

- `commit` -- before committing.
- `create-cli` -- before designing CLI UX, flags, output contracts, or command trees.
- `frontend-design` -- before creating/restyling UI.
- `github` -- GitHub/PR/CI work.
- `github-deep-review` -- deep GitHub issue/PR review: root cause, provenance, best fix, proof, risk.
- `google-workspace` -- Google Workspace tasks across Gmail, Drive, Calendar, Docs, Sheets.
- `librarian` -- referenced remote repos; use cached checkouts under `~/.cache/checkouts` instead of ad hoc clones.
- `mermaid` -- before creating/editing Mermaid diagrams.
- `skill-cleaner` -- audit skill budget, duplicates, usage, and stale skills.
- `summarize` -- convert URLs/docs/PDFs to Markdown.
- `tmux` -- before background jobs or interactive CLIs/debuggers.
- `update-changelog` -- before changelog edits.
- `uv` -- before Python deps/scripts/builds.
- `web-browser` -- live browser/UI inspection.
