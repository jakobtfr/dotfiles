# Agent Directives: Coding

READ ~/AGENTS.md BEFORE ANYTHING (skip if missing).

Coding-specific rules for projects in `~/code/`.

## Core

- Workspace: `~/code/projects` for own repos; `~/code/other` for 3rd-party/OSS. Missing jakobtfr repo: clone `https://github.com/jakobtfr/<repo>.git`.
- Shared skills live in `~/.agents/skills/`. Read `~/.agents/skills/<name>/SKILL.md` when relevant.
- Skills are canonical for tool workflows. Keep this file to coding hard rules and skill routing.

## Project Defaults

- Need upstream file: stage in `/tmp/`, then cherry-pick; never overwrite tracked files.
- Use repo package manager/runtime; no swaps without approval.
- TypeScript: use repo PM; keep files cohesive; follow existing patterns.
- Bugs: add regression test when it fits.
- Fixes/refactors: delete old paths by default. Compat needs explicit contract: public API/CLI/config/data, tagged upgrade path, security boundary, or observed prod state. If unsure, ask before keeping aliases/shims/fallbacks. Tests alone are not contracts.
- Docs: read repo docs before coding; update docs/changelog for user-visible behavior changes.
- Inline code comments: brief notes for tricky, bug-prone, or previously buggy logic.
- New deps: quick health check for recent releases/commits/adoption.
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
- GitHub broad reads: prefer shimmed `gh` / `gitcrawl gh` first. Raw `gh api search/* -f ...` needs `--method GET`; gitcrawl shim sanitizes this.
- Pasted GitHub issue/PR: first `git status -sb`; if dirty, yell; then `git push` + `git pull --ff-only`.
- PR refs: use `gh pr view/diff`, not web search.
- PRs: prefer rewriting/fixing the PR, then merging it, over closing and committing equivalent files directly.
- Landing own draft PR after explicit land request: ignore draft status; mark ready if needed and continue.
- `fix ci`: consent to pull, commit, push; fix/rerun/watch until CI green.
- CI: `gh run list/view`; rerun/fix until green when asked.
- `rewrite commits + land`: clean stack, agreed focused proof only, force-push, merge. No Codex review, PR-body proof polish, or CI babysitting unless asked.
- Pre-land/pre-commit code changes: run focused review until no accepted/actionable findings remain, unless equivalent manual review already done, trivial/docs-only, or user opts out.
- Replies: cite fix + file/line; resolve threads only after fix lands.
- Issue fixed on `main` with proof: comment proof + commit/PR, then close.
- User-facing fixes/landed PRs: update changelog unless pure test/internal.
- After landing: final includes 2-5 sentence recap of what landed.
- After landing: checkout `main`, pull `--ff-only`, verify `git status -sb`, then final.
- PR fixups from repo cwd: use that checkout. No worktrees unless asked; if awkward, ask.
- Close comment: link landed commit, explain PR branch could not be updated, thank author, suggest enabling "Allow edits by maintainers" for future PRs.

## Coding Git

- If cwd is in a git repo: work there. Do not jump to sibling checkout unless asked.
- No `git worktree` from CLI sessions unless user asks. If dirty/wrong branch/awkward: ask.
- Branch switch/checkout ok when task needs it and repo rules allow.
- `~/Projects` has many intentional same-repo checkouts. Treat as user-managed, not scratch.
- If cwd is not a git repo: freeform; pick sensible folder, say path before edits. Worktrees ok if useful.
- End in visible checkout/branch user expects.
- Commits: Conventional Commits (`feat|fix|refactor|build|ci|chore|docs|style|perf|test`).

## GitHub Write Safety

- Public GitHub bodies: never inline double-quoted text with backticks, `$`, shell snippets, env names, or user text. Use temp file + `cat <<'EOF'` + inspect + `--body-file`.
- PR/issue body edits: fetch via REST + `jq -r`, never `gh pr/issue view --json body --jq .body`. Example: `gh api repos/OWNER/REPO/pulls/NUM | jq -r '.body // ""' > /tmp/body.md`; inspect before `--body-file`; stop if it starts with `"` or shows literal `\n`.
- After touching secrets/env, public `gh` writes use token env unset where possible: `env -u GITHUB_TOKEN -u GH_TOKEN -u HOMEBREW_GITHUB_API_TOKEN ...`.

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
