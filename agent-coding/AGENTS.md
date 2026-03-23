# Agent Directives: Coding

READ ~/AGENTS.md BEFORE ANYTHING (skip if missing).

Coding-specific rules for projects in `~/code/`.

## Workspace
- `~/code/projects` -- own repos. Missing jakobtfr repo: clone `https://github.com/jakobtfr/<repo>.git`.
- `~/code/other` -- 3rd-party/OSS (non-jakobtfr).
- Editor: `nvim <path>`.
- Keep files <~500 LOC; split/refactor as needed.

## Commits & PRs
- Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).
- PRs: use `gh pr view/diff` (no URLs).
- PR comments: `gh pr view …` + `gh api …/comments --paginate`.
- Replies: cite fix + file/line; resolve threads only after fix lands.

## Build / Test / CI
- Before handoff: run full gate (lint/typecheck/tests/docs).
- CI red: `gh run list/view`, rerun, fix, push, repeat til green.
- Keep it observable (logs, panes, tails, MCP/browser tools).
- Use repo's package manager/runtime; no swaps w/o approval.
- Use Opencode background for long jobs; tmux only for interactive/persistent.

## Docs
- Open docs before coding.
- Follow links until domain makes sense; honor `Read when` hints.
- Keep notes short; update docs when behavior/API changes (no ship w/o docs).

## Screenshots ("use a screenshot")
- Pick newest PNG in `~/Desktop` or `~/Downloads`.
- Verify it's the right UI (ignore filename).
- Size: `sips -g pixelWidth -g pixelHeight <file>` (prefer 2×).
- Optimize: `imageoptim <file>`.

## Language/Stack Notes
- TypeScript: use repo PM; keep files small; follow existing patterns.

## Tools
- `gh` -- GitHub CLI for PRs/CI/releases. Given issue/PR URL: use `gh`, not web search.

## Skills
Read `~/agent-coding/skills/` for the full skill catalog.
- `create-cli/` -- CLI design (syntax, flags, output contracts)
- `frontend-design/` -- Frontend aesthetics (anti-AI-slop rules)
- `deepwiki/` -- Query public GitHub repos via DeepWiki CLI

<frontend_aesthetics>
Avoid "AI slop" UI. Be opinionated + distinctive.

Do:
- Typography: pick a real font; avoid Inter/Roboto/Arial/system defaults.
- Theme: commit to a palette; use CSS vars; bold accents > timid gradients.
- Motion: 1–2 high-impact moments (staggered reveal beats random micro-anim).
- Background: add depth (gradients/patterns), not flat default.

Avoid: purple-on-white clichés, generic component grids, predictable layouts.
</frontend_aesthetics>
