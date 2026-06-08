---
name: web-browser
description: "Low-level fallback browser controls for raw Chrome DevTools Protocol work, manual element picking, cookie dialog dismissal, and local console/network logging. Prefer agent-browser for normal browser automation."
---

# Web Browser Skill

Low-level CDP tools for browser debugging escape hatches.

## Default: Use agent-browser

For normal browser automation, use `agent-browser` instead of these scripts:

```bash
agent-browser skills get core
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser click @e3
agent-browser fill @e4 "text"
agent-browser wait --load networkidle
agent-browser screenshot
```

`agent-browser` is the default for:
- opening/navigating pages
- clicking, filling, typing, selecting, hovering, scrolling, dragging, uploading
- extracting text, HTML, attributes, values, counts, boxes, and styles
- screenshots, PDFs, annotated screenshots, diffs, traces, profiling, and video
- waits, tabs, frames, dialogs, cookies, storage, auth state, sessions, and network interception
- React tree/render/vitals inspection
- cloud/browser-provider workflows

Run `agent-browser doctor` when the CLI/browser setup behaves unexpectedly.

## Use These Scripts Only For

- Cookie banners: `dismiss-cookies.js` has focused EU CMP heuristics.
- Manual visual picking: `pick.js` lets a human select elements in the live page.
- Raw CDP debugging: scripts are small and patchable when `agent-browser` abstracts too much.
- Conservative profile copy behavior: `start.js --profile` copies the Chrome profile into cache and refuses unknown `:9222` instances.
- Local JSONL console/network logging: `watch.js`, `logs-tail.js`, and `net-summary.js`.

Start these commands from this skill directory:

```bash
cd ~/code/dotfiles/agent-coding/skills/web-browser
```

## Start Chrome

```bash
./scripts/start.js                  # Isolated reusable profile (default)
./scripts/start.js --profile        # Copy your profile into isolated cache
./scripts/start.js --reset-profile  # Clear selected cached profile before launch
```

Starts Chrome with remote debugging (default port `:9222`).

Profile behavior:
- Default mode uses: `~/.cache/agent-web/browser/fresh-profile`
- `--profile` mode uses: `~/.cache/agent-web/browser/profile-copy`
- The skill **does not attach to your live Chrome profile directly**
- If `:9222` is already used by an unknown instance, start will fail instead of reusing it

If Chrome is installed in a non-standard location, set:

```bash
BROWSER_BIN=/path/to/chrome ./scripts/start.js
```

Optional debug endpoint override:

```bash
BROWSER_DEBUG_PORT=9333 ./scripts/start.js
```

Prefer `agent-browser open --headed <url>` unless you specifically need this
local profile-copy/port behavior.

## Navigate Fallback

```bash
./scripts/nav.js https://example.com
./scripts/nav.js https://example.com --new
```

Navigate current tab or open new tab.

Prefer:

```bash
agent-browser open --device "iPhone 14" https://example.com
agent-browser set viewport 390 844 3
```

Use this fallback when working with the local Chrome instance launched by
`start.js`.

## Device Emulation Fallback

```bash
./scripts/emulate.js --list
./scripts/emulate.js iphone-14
./scripts/emulate.js pixel-7 --landscape
./scripts/emulate.js --reset
```

Set an active device emulation preference (viewport, DPR, touch, UA) for browser skill commands. Use `--reset` to clear.

Commands like `nav.js`, `eval.js`, `pick.js`, `dismiss-cookies.js`, and `screenshot.js` automatically apply the active preference.

## Evaluate JavaScript Fallback

Prefer:

```bash
cat <<'EOF' | agent-browser eval --stdin
document.title
EOF
```

Use the local script only for raw CDP work against the `start.js` browser.

```bash
./scripts/eval.js 'document.title'
./scripts/eval.js 'document.querySelectorAll("a").length'
./scripts/eval.js 'JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => ({ text: a.textContent.trim(), href: a.href })).filter(link => !link.href.startsWith("https://")))'
```

Execute JavaScript in active tab (async context). Be careful with string escaping, best to use single quotes.

## Screenshot Fallback

Prefer:

```bash
agent-browser screenshot
agent-browser screenshot --full
agent-browser screenshot --annotate
```

Use the local script only for screenshots from the `start.js` browser.

```bash
./scripts/screenshot.js
./scripts/screenshot.js --full-page
./scripts/screenshot.js --device iphone-14
./scripts/screenshot.js --device pixel-7 --full-page
```

Takes a screenshot and returns a temp file path.

- Default: current viewport
- `--full-page`: captures full document height
- `--device <preset>`: temporary mobile emulation for that screenshot only

## Pick Elements

```bash
./scripts/pick.js "Click the submit button"
```

Interactive element picker. Click to select, Cmd/Ctrl+Click for multi-select, Enter to finish.

Use this when a human needs to visually choose elements. For agent-only element
selection, prefer:

```bash
agent-browser snapshot -i
agent-browser screenshot --annotate
agent-browser find role button click --name "Submit"
```

## Dismiss Cookie Dialogs

```bash
./scripts/dismiss-cookies.js          # Accept cookies
./scripts/dismiss-cookies.js --reject # Reject cookies (where possible)
```

Automatically dismisses EU cookie consent dialogs.

Run after navigating to a page:
```bash
./scripts/nav.js https://example.com && ./scripts/dismiss-cookies.js
```

For `agent-browser`, first try snapshot-driven dismissal:

```bash
agent-browser snapshot -i
agent-browser click @e3
```

If cookie banners remain a frequent problem, start the local CDP browser and use
this script.

## Quick Local Mobile Debug Flow

```bash
./scripts/start.js
./scripts/nav.js https://example.com
./scripts/emulate.js iphone-14
./scripts/nav.js https://example.com      # reload with mobile UA
./scripts/dismiss-cookies.js
./scripts/screenshot.js --full-page
```

Prefer this `agent-browser` flow unless the local JSONL logs are specifically
useful:

```bash
agent-browser open --device "iPhone 14" https://example.com
agent-browser wait --load networkidle
agent-browser console
agent-browser errors
agent-browser network requests
agent-browser screenshot --full
```

## Background Logging Fallback (Console + Errors + Network)

Automatically started by `start.js` and writes JSONL logs to:

```
~/.cache/agent-web/logs/YYYY-MM-DD/<targetId>.jsonl
```

Manually start:
```bash
./scripts/watch.js
```

Tail latest log:
```bash
./scripts/logs-tail.js           # dump current log and exit
./scripts/logs-tail.js --follow  # keep following
```

Summarize network responses:
```bash
./scripts/net-summary.js
```

Prefer `agent-browser console`, `agent-browser errors`, `agent-browser network
requests`, and `agent-browser network har start/stop` for normal work.
