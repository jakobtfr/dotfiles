---
name: review-loop
description: "Run a code-review loop: delegate to a reviewer agent with the environment's /review command, apply requested fixes, and repeat until no requested changes remain. Use before commit, PR, landing, or handoff when code changes need an independent review pass."
---

# Review Loop

Use this as a driver for independent review. The reviewer agent reviews; the main agent owns fixes, test proof, and final judgment.

## Loop

1. Start after the intended code changes are ready and the narrowest useful local check has either passed or the current failure is understood.
2. Start one reviewer agent using the current environment's normal delegation/subagent mechanism. Give it the relevant task context and current workspace/diff access available in that environment.
3. Make the reviewer prompt start with `/review` so the environment's review command runs, not a custom imitation:

```text
/review
Review the current workspace diff. Focus on correctness bugs, regressions, missing tests, and local-instruction violations. Return actionable requested changes with file/line references. If none remain, say "No requested changes."
```

4. Wait for the review result. Treat concrete requested changes as blocking unless they are clearly false positives, conflict with user intent, or would widen scope without improving correctness.
5. For each accepted request, make the smallest cohesive fix in the main workspace. Run focused tests or checks for the changed surface.
6. Send the same reviewer another message that starts with `/review`, summarize what changed, and ask it to review again:

```text
/review
I addressed the requested changes: <brief bullets>. Please review the updated workspace diff again. If no requested changes remain, say "No requested changes."
```

7. Repeat until the reviewer either reports no requested changes or explicitly accepts the rationale for any non-applied request.
8. Close or release the reviewer when done, if the environment exposes that lifecycle.

## Rules

- Do not stop after the first review when accepted requested changes were applied; rerun `/review`.
- Do not silently ignore a requested change. Fix it, or explain the rejection to the reviewer and get a clean/no-change follow-up.
- If the reviewer environment is an isolated fork and cannot see parent-side fixes, run each follow-up `/review` in a fresh reviewer against the updated workspace. Keep the same loop contract.
- Keep the review scope to the current task diff. Avoid broad refactors unless the review finding proves they are needed.
- Final response: mention review iterations, requested changes fixed or rejected with rationale, and tests/checks run.
