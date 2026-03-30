---
date: 2026-03-22
tags: [config, agents, workflow]
---

# Agent Setup

The canonical reference for the agent configuration lives in `~/AGENTS.md` (source: `~/code/dotfiles/AGENTS.md`), under the **Setup Map** section.

For Codex specifically, chezmoi also deploys the same content to `~/.codex/AGENTS.md`. Codex reads `AGENTS.md` from `$CODEX_HOME`, so this guarantees the global instructions are loaded even when Codex starts outside `~/` or outside any repo.

Read that file for the full config chain, source-of-truth paths, and sync workflow.
