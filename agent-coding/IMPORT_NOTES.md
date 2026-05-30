# Agent Scripts Import Notes

Imported from `../agent-scripts` as a broad first pass for later pruning.

## Active Skills Imported

- `browser-use`
- `cloudflare-registrar`
- `codex-debugging`
- `create-cli`
- `github-author-context`
- `github-cache-hygiene`
- `github-deep-review`
- `github-project-triage`
- `markdown-converter`
- `nano-banana-pro`
- `notcrawl`
- `npm`
- `obsidian`
- `one-password`
- `openai-image-gen`
- `oracle`
- `peekaboo`
- `skill-cleaner`
- `ssh-doctor`
- `twilio-sms`
- `video-transcript-downloader`
- `vm-lab`
- `wrangler`
- `xurl`

## Docs Imported

- `RELEASING.md`
- `concurrency.md`
- `npm-publish-with-1password.md`
- `slash-commands.md`
- `subagent.md`
- `update-changelog.md`
- `windows.md`
- `slash-commands/acceptpr.md`
- `slash-commands/fixissue.md`
- `slash-commands/handoff.md`
- `slash-commands/landpr.md`
- `slash-commands/pickup.md`
- `slash-commands/raise.md`

## Scripts Imported

- `browser-tools.ts`
- `docs-list.ts`
- `nanobanana`
- `trash.ts`
- `validate-skills`

`validate-skills` was adapted to validate `agent-coding/skills`.

## Candidates For Manual Merge

- `candidates/skills/frontend-design` conflicts with existing `skills/frontend-design`.
- `candidates/docs/slash-commands-README.md` conflicts with existing slash-command README.
- `candidates/hooks-pre-commit` is useful only if this repo adopts the validation hook.

## Skipped

- `scripts/committer` per preference.
- OpenClaw/product skills.
- Swift/mac app release and profiling skills.
- Beeper/WhatsApp/Sonos/Things/Reminders-style personal automation skills.
- Mac release docs and GHSA-specific `/sectriage`.
