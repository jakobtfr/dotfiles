---
name: deepwiki
description: >
  Query public GitHub repositories via DeepWiki to understand their internals,
  architecture, APIs, and patterns. Use when the user asks about how a library,
  framework, or tool works internally, or when you need to understand a
  dependency before integrating it.
---

# DeepWiki

Query public GitHub repos for architectural understanding without cloning.

## Trigger
- User asks "how does X work in repo Y?"
- User asks about internals of a library/framework
- You need to understand a dependency's architecture before integrating

## Prerequisites
- `deepwiki-cli` installed: `brew tap hamsurang/deepwiki-cli && brew install deepwiki-cli`
- Only works with **public** GitHub repos

## Commands

### Explore structure first
```bash
deepwiki-cli structure owner/repo
```
Returns the wiki topic tree. Use this to understand what's documented before asking specific questions.

### Ask a specific question
```bash
deepwiki-cli ask owner/repo "How does authentication work?"
```
Returns an AI-generated answer grounded in the repo's code.

### Read full wiki
```bash
deepwiki-cli read owner/repo
```
Returns the entire wiki. Large output -- only use when you need broad understanding, not for targeted questions.

## Workflow

1. **Start with `structure`** to see what topics exist.
2. **Ask targeted questions** based on the structure. Be specific -- "How does the router match paths?" is better than "How does routing work?"
3. **Verify against source** if the answer is critical. DeepWiki can be wrong. For important integration decisions, confirm by reading actual source files.

## When NOT to Use
- Private repos (won't work)
- Repos you've already cloned (just read the code directly)
- Simple API usage questions (check the README or docs first)
- When the repo is small enough to skim directly
