---
name: tmux
description: "Run long-running jobs and remote-control interactive CLIs/debuggers in detached private tmux sessions. Use for background tests/builds/dev servers/watchers, REPLs, lldb/gdb, and other persistent terminal work."
license: Vibecoded
---

# tmux Skill

Use tmux when a command should keep running while the agent continues working, or when a process needs an interactive TTY. Works on Linux and macOS with stock tmux.

Do **not** use the user's normal tmux server. Use a private socket path with `tmux -S "$SOCKET"`.

## When to use

Use tmux for:
- long-running tests/builds/checks that may exceed normal tool timeouts
- dev servers and file watchers
- background logs/tails
- REPLs, shells, database consoles, debuggers
- any interactive process that needs repeated input/output inspection

Do not use tmux for quick commands that can run directly and finish promptly.

## Socket convention

```bash
SOCKET_DIR="${PI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/pi-tmux-sockets}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/pi.sock"
SESSION="pi-<short-task-name>"
```

Rules:
- Always use `tmux -S "$SOCKET"` with the private socket path.
- Keep session names short and slug-like: `pi-tests`, `pi-dev`, `pi-lldb`.
- Target panes as `{session}:{window}.{pane}`; default pane is usually `$SESSION:0.0`.
- Inspect sessions with `tmux -S "$SOCKET" list-sessions` and panes with `tmux -S "$SOCKET" list-panes -a`.

## Always print monitor commands

After starting a session, immediately tell the user how to monitor it. Repeat the commands again in the final response if the session is still running.

```text
To monitor:
  tmux -S "$SOCKET" attach -t "$SESSION"

To capture output once:
  tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200
```

This is required. The user should be able to copy/paste without reconstructing state.

## Long-running non-interactive command

Use this for tests/builds/checks where the pane should stay open after completion and expose the exit code:

```bash
SOCKET_DIR="${PI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/pi-tmux-sockets}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/pi.sock"
SESSION="pi-tests-$(date +%H%M%S)"
CMD='pnpm test'

tmux -S "$SOCKET" new-session -d -s "$SESSION" -n run \
  "bash -lc 'set -o pipefail; $CMD 2>&1; code=\$?; echo; echo __PI_EXIT__:\$code; exec bash -i'"

echo "To monitor: tmux -S '$SOCKET' attach -t '$SESSION'"
echo "To capture: tmux -S '$SOCKET' capture-pane -p -J -t '$SESSION':0.0 -S -200"
```

Later, inspect output:

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -300
```

Look for `__PI_EXIT__:0` or a non-zero exit marker. If the marker is absent, the job is still running or did not reach the wrapper tail.

## Dev server / watcher

Use this for persistent processes:

```bash
SOCKET_DIR="${PI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/pi-tmux-sockets}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/pi.sock"
SESSION="pi-dev-$(date +%H%M%S)"

tmux -S "$SOCKET" new-session -d -s "$SESSION" -n server \
  "bash -lc 'pnpm dev'"

echo "To monitor: tmux -S '$SOCKET' attach -t '$SESSION'"
echo "To capture: tmux -S '$SOCKET' capture-pane -p -J -t '$SESSION':0.0 -S -200"
```

Poll readiness with `capture-pane`, `rg`, `curl`, or the app's health check.

## Sending input safely

Prefer literal sends to avoid shell splitting:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- "$cmd"
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

Control keys:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 C-c
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 C-d
```

## Watching output

Capture recent history, joined to avoid wrapping artifacts:

```bash
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION":0.0 -S -200
```

For continuous monitoring, poll with `capture-pane` or use the helper script below. Do not use `tmux wait-for` for pane text; it does not watch output.

## Finding sessions

From this skill directory:

```bash
./scripts/find-sessions.sh -S "$SOCKET"
./scripts/find-sessions.sh --all
```

`--all` scans sockets under `${PI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/pi-tmux-sockets}`.

## Synchronizing / waiting for prompts

Use timed polling to avoid races with interactive tools. From this skill directory:

```bash
./scripts/wait-for-text.sh -S "$SOCKET" -t "$SESSION":0.0 -p '^>>>' -T 15 -l 4000
```

If the helper in this checkout does not support `-S`, pass the socket through `TMUX`-compatible environment or fall back to a short `while` loop around `tmux -S "$SOCKET" capture-pane`.

## Interactive recipes

### Python REPL

Use the basic REPL so send-keys works predictably:

```bash
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n py \
  "bash -lc 'PYTHON_BASIC_REPL=1 python3 -q'"
./scripts/wait-for-text.sh -t "$SESSION":0.0 -p '^>>>' -T 15 -l 4000
```

Then send code literally with `send-keys -l` and press Enter.

### lldb / gdb

Prefer `lldb` on macOS unless the project expects `gdb`.

```bash
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n debug \
  "bash -lc 'lldb -- ./target/debug/app'"
```

For gdb, disable paging after startup:

```bash
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 -l -- 'set pagination off'
tmux -S "$SOCKET" send-keys -t "$SESSION":0.0 Enter
```

## Cleanup

When done, clean up sessions you started:

```bash
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

Kill all sessions on the private socket only when appropriate:

```bash
tmux -S "$SOCKET" kill-server
```

Do not kill the user's normal tmux server.

## Helper: wait-for-text.sh

`./scripts/wait-for-text.sh` polls a pane for a regex or fixed string.

```bash
./scripts/wait-for-text.sh -t session:0.0 -p 'pattern' [-F] [-T 20] [-i 0.5] [-l 2000]
```

- `-t`/`--target` pane target (required)
- `-p`/`--pattern` regex to match (required); add `-F` for fixed string
- `-T` timeout seconds (integer, default 15)
- `-i` poll interval seconds (default 0.5)
- `-l` history lines to search from the pane (integer, default 1000)
- exits 0 on first match, 1 on timeout; on failure prints captured text to stderr
