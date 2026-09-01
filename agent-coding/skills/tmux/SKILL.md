---
name: tmux
description: "Fallback for persistent, user-attachable terminal sessions when a server, watcher, debugger, or long job must outlive the current agent session."
---

# tmux

Use the harness's native persistent process or PTY for routine commands,
interactive input, and jobs that only need to survive individual tool calls.
Use tmux only when the process needs an independent lifetime or the user needs
to attach directly.

Use tmux when:

- a server, watcher, or long job must survive the current agent/app session
- the user needs an independent attachable terminal
- multiple agents or runtimes need the same terminal
- persistent pane history or multiple panes materially help

Do not use tmux for quick commands, ordinary tests, or background work that a
native session can keep alive long enough.

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

For a long batch job that must survive the current agent session, expose its
exit status and leave the pane available:

```sh
CMD='pnpm run benchmark'
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
