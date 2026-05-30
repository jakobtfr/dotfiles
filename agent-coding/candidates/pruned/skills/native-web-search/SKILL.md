---
name: native-web-search
description: "Trigger native web search. Use when you need quick internet research with concise summaries and full source URLs."
---

# Native Web Search

Use this skill to run a **fast model with native web search enabled** and get a concise research summary with explicit full URLs.

## Script

- `search.mjs`

## Usage

Run from this skill directory:

```bash
node search.mjs "<what to search>" --purpose "<why you need this>"
```

Examples:

```bash
node search.mjs "latest python release" --purpose "update dependency notes"
node search.mjs "HTTP/3 browser support 2026" --provider openai
node search.mjs "vite 7 breaking changes" --purpose "prepare migration checklist"
```

Optional flags:

- `--provider openai|openai-codex|anthropic`
- `--model <model-id>`
- `--timeout <ms>`
- `--json`

## Output expectations

The script instructs the model to:
- search the internet for the requested topic
- provide a concise summary for the given purpose
- include full canonical URLs (`https://...`) for each key finding
- highlight disagreements between sources

## Notes

- No extra npm install is required.
- API-key auth works without a harness-specific helper module.
- OAuth token refresh currently uses the Pi AI helper when needed. Set `AGENT_AI_MODULE_PATH` or legacy `PI_AI_MODULE_PATH` to its `dist/index.js` path if module resolution fails.
- If OAuth helper resolution fails, set `AGENT_AI_OAUTH_MODULE_PATH` or legacy `PI_AI_OAUTH_MODULE_PATH` to the helper's `dist/oauth.js` path.
- `openai` uses the OpenAI Responses API (`https://api.openai.com/v1/responses`) with the native `web_search` tool.
- `openai-codex` is only for explicit ChatGPT/Codex subscription OAuth usage.
- The auth directory defaults to `AGENT_AUTH_DIR`, then legacy `PI_CODING_AGENT_DIR`, then `~/.pi/agent`.
- For OAuth providers, the script can fall back to a still-valid cached `access` token from the selected `auth.json`.
