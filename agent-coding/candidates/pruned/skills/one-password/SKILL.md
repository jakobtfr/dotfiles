---
name: one-password
description: "1Password/op: targeted secret read/store/inject, tmux, no broad dumps."
---

# 1Password CLI

Use this for 1Password CLI (`op`) work involving secrets, API keys, TOTP, or
credential injection.

## References

- Official docs: https://developer.1password.com/docs/cli/get-started/
- `references/get-started.md`
- `references/cli-examples.md`

## Rules

- Never print secrets, full item JSON, tokens, passwords, TOTP codes, or broad secret dumps.
- Never run `env`, `set`, `export -p`, or broad regex scans to find secrets.
- Query exact item/field names only. If the item/vault/account is ambiguous, ask.
- Prefer `op run` / `op inject` over writing secrets to disk.
- If writing a temp script, use `set +x`, mode `700`, and delete it after use.
- Print shape only when debugging: field present, length, expected prefix class, newline count.

## Tmux Rule

Run `op` inside one persistent tmux session for the whole secret task. This keeps
desktop/app auth state stable and avoids repeated prompts.

```bash
SOCKET_DIR="${AGENT_TMUX_SOCKET_DIR:-${PI_TMUX_SOCKET_DIR:-${TMPDIR:-/tmp}/agent-tmux-sockets}}"
mkdir -p "$SOCKET_DIR"
SOCKET="$SOCKET_DIR/op.sock"
SESSION="op-work"

tmux -S "$SOCKET" has-session -t "$SESSION" 2>/dev/null ||
  tmux -S "$SOCKET" new -d -s "$SESSION" -n shell
tmux -S "$SOCKET" send-keys -t "$SESSION:" -- "op signin" Enter
tmux -S "$SOCKET" send-keys -t "$SESSION:" -- "op whoami" Enter
tmux -S "$SOCKET" capture-pane -p -J -t "$SESSION:" -S -200
```

Do not start a second session after quoting, item-name, or command failures.
Send a corrected command into the existing session.

## Targeted Field Read

Use exact item/vault/field labels. Keep extraction scoped and shape-only:

```bash
cat > /tmp/op-read-field.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
set +x
ITEM_TITLE="Known API Credential Item"
FIELD_LABEL="api_token"
VAULT="Private"
value="$(
  op item get "$ITEM_TITLE" --vault "$VAULT" --format json |
    FIELD_LABEL="$FIELD_LABEL" node -e 'let s=""; process.stdin.on("data",d=>s+=d); process.stdin.on("end",()=>{const item=JSON.parse(s); const f=(item.fields||[]).find(x=>x.label===process.env.FIELD_LABEL); if(!f?.value) process.exit(2); process.stdout.write(f.value);})'
)"
echo "field_len:${#value}"
case "$value" in sk-*) echo "field_prefix:sk" ;; *) echo "field_prefix:other" ;; esac
echo "field_has_newline:$(printf %s "$value" | wc -l | tr -d ' ')"
SCRIPT
chmod 700 /tmp/op-read-field.sh
tmux -S "$SOCKET" send-keys -t "$SESSION:" -- "bash /tmp/op-read-field.sh; rm -f /tmp/op-read-field.sh" C-m
```

## Store A Secret

Prefer a known vault/item/field. Read the secret from a current local source such
as clipboard only when the user explicitly provided it for this task.

```bash
cat > /tmp/op-store-secret.sh <<'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
set +x
VAULT="Private"
ITEM_TITLE="Service API Tokens"
FIELD_NAME="api_token"
TOKEN="$(pbpaste)"
op item create --category "API Credential" --vault "$VAULT" \
  --title "$ITEM_TITLE" "$FIELD_NAME[password]=$TOKEN" >/dev/null
op item get "$ITEM_TITLE" --vault "$VAULT" --fields "label=$FIELD_NAME" >/dev/null
echo "stored and verified secret field without printing it"
SCRIPT
chmod 700 /tmp/op-store-secret.sh
tmux -S "$SOCKET" send-keys -t "$SESSION:" -- "bash /tmp/op-store-secret.sh; rm -f /tmp/op-store-secret.sh" C-m
```

## Metadata Search

Only search when the user explicitly asks, gives a screenshot/listing, or the
exact title failed and they ask for fuzzy lookup. Stay vault-scoped and print
metadata only.
