---
name: review-fix
description: "Run one code-review fix pass before commit, PR, landing, or handoff."
---

# Review Fix

Use this as a driver for independent review. The reviewer agent reviews; the main agent owns fixes, test proof, and final judgment.

## Review

1. Start after the intended code changes are ready and the narrowest useful local check has either passed or the current failure is understood.
2. Start one reviewer agent using the current environment's normal delegation/subagent mechanism. Give it the relevant task context and current workspace/diff access available in that environment.
3. Make the reviewer prompt start with `/review` so the environment's review command runs, not a custom imitation:

```text
/review
Review the current workspace diff. Focus on correctness bugs, regressions, missing tests, and local-instruction violations. Return actionable requested changes with file/line references. If none remain, say "No requested changes."
```

4. Wait for the review result. Treat concrete requested changes as blocking unless they are clearly false positives, conflict with user intent, or would widen scope without improving correctness.
5. For each accepted request, make the smallest cohesive fix in the main workspace. Run focused tests or checks for the changed surface.
6. Close or release the reviewer when done, if the environment exposes that lifecycle.

## Rules

- Run `/review` once. Do not rerun it after applying accepted requested changes.
- Do not silently ignore a requested change. Fix it, or explain the rejection in the final response.
- Keep the review scope to the current task diff. Avoid broad refactors unless the review finding proves they are needed.
- Final response: mention requested changes fixed or rejected with rationale, and tests/checks run.
