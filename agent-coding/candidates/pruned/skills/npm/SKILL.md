---
name: npm
description: "npm registry ops: login, whoami, package names, publish, auth debugging."
---

# npm

Use for npm registry/account tasks: `npm whoami`, package availability, package
reservation, publishing, org checks, and auth debugging.

## Auth

- Use `one-password` first for secret rules when credentials or TOTP are needed.
- Never run `op` directly in the shell tool; use the persistent tmux flow from `one-password`.
- Keep npm auth in a temp npmrc; delete it after the command.
- Prefer existing repo release docs and package manager scripts over ad hoc publish commands.
- Explicit user requests to `release`, `publish`, or `npm publish` are consent to complete expected npm auth prompts for that publish flow.
- Still stop and ask if the account/vault is ambiguous, credentials are malformed, npm denies package access, or the requested package/version does not match the repo release target.
- Avoid `expect` for npm login unless necessary; logs can echo prompts and are easy to get wrong.

## Basic Checks

```bash
npm whoami
npm view <pkg> version dist-tags time --json
npm access get status <pkg>
```

Use a throwaway npm config for authenticated checks:

```bash
NPM_CONFIG_USERCONFIG="$(mktemp)"
trap 'rm -f "$NPM_CONFIG_USERCONFIG"' EXIT
npm whoami --userconfig "$NPM_CONFIG_USERCONFIG"
```

## Package Reservation

Use `scripts/reserve-packages.sh` from this skill directory when explicitly
asked to reserve names:

```bash
./scripts/reserve-packages.sh package-one package-two
```

What it does:
- reads npm credentials once through `op`
- creates an npm registry session
- publishes `0.0.0` placeholder packages with a generic README
- continues after per-package publish failures
- redacts tokens/OTP in logs
- cleans temp npmrc/work dirs

Notes:
- npm may reject names as too similar to already-published names. Treat that as a registry policy result, not an auth failure.
- For scoped packages, `npm view` can lag/404 even when the package exists. Check `npm access get status <pkg>`.
