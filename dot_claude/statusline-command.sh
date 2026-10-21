#!/bin/sh
# Claude Code status line: model | effort | context usage
# Reads the session JSON payload from stdin (see statusline docs for schema).

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // .model.id // "model?"')

effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')
if [ -z "$effort" ]; then
  effort="n/a"
fi

# context_window.used_percentage is the pre-calculated "% of context window
# used" field Claude Code provides; falls back to "?" if no messages yet
# (e.g. right at session start) since the field is null in that case.
ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx_pct" ]; then
  ctx=$(printf '%.0f' "$ctx_pct")
else
  ctx="?"
fi

printf '%s | %s | ctx %s%%\n' "$model" "$effort" "$ctx"
