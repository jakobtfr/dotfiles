---
name: web-browser
description: "Browser automation with agent-browser; local Chrome/CDP fallbacks."
---

# Web Browser

Use `agent-browser` for normal browser automation and UI verification. This skill makes that CLI discoverable across harnesses and retains local CDP scripts for cases it does not cover well.

## Default Workflow

Load the current CLI guide, then inspect before interacting:

```sh
agent-browser skills get core
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser click @e3
agent-browser fill @e4 "text"
agent-browser wait --load networkidle
```

Verify behavior and visual state, not only page source:

```sh
agent-browser console
agent-browser errors
agent-browser network requests
agent-browser screenshot --full
```

Use `agent-browser doctor` when setup fails. Prefer its snapshots, locators, waits, tabs, frames, cookies, storage, auth state, network interception, traces, and screenshots over custom CDP code.

For JavaScript, avoid shell-escaping problems:

```sh
cat <<'EOF' | agent-browser eval --stdin
document.title
EOF
```

## Local CDP Fallbacks

Run scripts from this skill directory. Use them only for:

- `start.js --profile`: copy the existing Chrome profile into an isolated cache for profile-dependent pages
- `pick.js`: let the user visually select elements
- `dismiss-cookies.js`: apply focused EU consent heuristics after snapshot-driven dismissal fails
- `watch.js`, `logs-tail.js`, `net-summary.js`: retain local JSONL console/network logs
- raw CDP behavior that `agent-browser` hides

```sh
./scripts/start.js --profile
./scripts/nav.js https://example.com
./scripts/pick.js "Select the affected element"
./scripts/dismiss-cookies.js --reject
./scripts/logs-tail.js
```

The profile is copied to `~/.cache/agent-web/browser/profile-copy`; the scripts never attach directly to the live profile. They refuse an unknown process on the debug port rather than reusing it.

For mobile checks, prefer `agent-browser open --device "iPhone 14" <url>`. The local `emulate.js` and `screenshot.js` remain available when debugging the CDP fallback browser.
