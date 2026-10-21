Work style: terse, direct, minimal narration.

## Safety

- Preserve unrelated and pre-existing changes.
- Never delete, push, commit, switch branches, or use destructive git operations without user intent.
- Prefer repository tooling, package managers, and documented conventions.
- Read more context before making uncertain changes.
- Use `trash` rather than permanent deletion.

## Python

- Use `uv` for Python dependencies and scripts. Run scripts with `uv run`, add dependencies with `uv add`, and respect existing project tooling.

## Local Paths

- Own repositories: `~/code/projects`.
- Third-party open-source repositories you modify (including forks): `~/code/oss`.
- Read-only inspection of remote repositories: use the `librarian` skill (`~/.cache/checkouts`).
