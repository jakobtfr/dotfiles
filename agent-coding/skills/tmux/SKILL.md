---
name: tmux
description: "Persistent user-attachable terminal sessions for long jobs, servers, watchers, REPLs, and debuggers."
---

# tmux

Prefer the harness's native persistent process or PTY session for routine long-running commands and interactive input.

Use tmux when:

- the process must survive harness calls, reconnects, or turn boundaries
- the user needs an independent attachable terminal
- multiple agents or runtimes need the same terminal
- persistent pane history or multiple panes materially help
- the harness has no suitable persistent process session

Do not use tmux for quick commands or when a native session provides the needed lifetime and interaction.

## Private Socket

Never use the user's normal tmux server.

```bash
SOCKET_DIR="${AGENT_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/agent-tmux-sockets}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/agent.sock"
SESSION="agent-task-$(date +%H%M%S)"
```

Always pass `-S "$SOCKET"`. Keep session names short and task-specific.

## Start

For a command that should expose its exit status and leave the pane available:

```sh
CMD='pnpm test'
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n run \
  "bash -lc 'set -o pipefail; $CMD 2>&1; code=\$?; echo; echo __AGENT_EXIT__:\$code; exec bash -i'"
```

For a persistent server or watcher:

```sh
CMD='pnpm dev'
tmux -S "$SOCKET" new-session -d -s "$SESSION" -n server \
  "bash -lc '$CMD'"
```

Set `CMD` only from trusted task commands. For complex quoting, put the command in a project script and invoke that script.

## Report and Monitor

Immediately print exact monitor commands. Repeat them in the final response if the session remains active.

```text
To monitor: tmux -S '<socket>' attach -t '<session>'
To capture: tmux -S '<socket>' capture-pane -p -J -t '<session>' -S -200
```

Poll output and readiness with:

```sh
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION" -S -200
```

For prompt synchronization, run from this skill directory:

```sh
./scripts/wait-for-text.sh -S "$SOCKET" -t "$SESSION" -p '^>>>' -T 15 -l 4000
```

Send literal input separately from Enter:

```sh
tmux -S "$SOCKET" send-keys -t "$SESSION" -l -- "$input"
tmux -S "$SOCKET" send-keys -t "$SESSION" Enter
tmux -S "$SOCKET" send-keys -t "$SESSION" C-c
```

## Cleanup

Kill sessions when their task is finished:

```sh
tmux -S "$SOCKET" kill-session -t "$SESSION"
```

Find sessions left on agent sockets:

```sh
./scripts/find-sessions.sh -S "$SOCKET"
./scripts/find-sessions.sh --all
```
