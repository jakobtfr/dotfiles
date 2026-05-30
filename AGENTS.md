Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## Core

- "Make a note" here => terse `AGENTS.md` edit. No separate `CLAUDE.md` here.
- Skills are canonical for tool workflows. Keep this file to hard rules only.
- Editing here/skills: token-efficient, relaxed grammar, terse descriptions.
- Skill descriptions: short generic trigger phrase, not summary; no personal names, long paths, or workflow narration unless needed for routing.
- Skill frontmatter: quote `description`; after SKILL.md edits, YAML-parse frontmatter before commit.

## Routing

- **Coding:** read `~/agent-coding/AGENTS.md` when working in `~/code/`.
- **Notes:** read the vault's `AGENTS.md` when working in the notes vault.
- **Skills:** use `~/.agents/skills/<name>/SKILL.md` when relevant.
- Screenshots/assets: newest PNG in `~/Desktop` or `~/Downloads`; verify UI before replacing.
- Screenshot/live UI bugs: verify with `web-browser` against the existing Chrome profile. `curl`/source proof is supporting only; no Playwright/Puppeteer/in-app browser for login/profile-dependent pages unless explicitly requested.
- Private/history: local archives first; verify freshness for current questions.

## Runtime Safety

- Unsure: read more context; if still stuck, ask w/ short options.
- Conflicts: call out; pick safer path.
- Never delete without user intent; use `trash` for removals.
- New deps: quick health check for recent releases/commits/adoption.
- Web: search early with available search/tool; quote exact errors; prefer 2024-2026 sources.
- zsh: don't use `status` as a variable.
- Secrets: never run `env`, `set`, `export -p`, or broad secret regex dumps in a normal shell. Query exact names only; redact values.

## Git

- Safe by default: `git status/diff/log`.
- Push only when user asks.
- Branch changes require user consent.
- Destructive ops forbidden unless explicit: `reset --hard`, `clean`, `restore`, `rm`, etc.
- No repo-wide S/R scripts; keep edits small/reviewable.
- If user types a command ("pull and push"), that's consent for that command.
- No amend unless asked.
- Unrecognized changes: assume other agent; keep going; focus your changes. If it causes issues, stop + ask user.
