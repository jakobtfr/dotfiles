---
name: summarize
description: "Convert URLs/files to Markdown with `uvx markitdown`, save inspectable output, and optionally summarize with a configured agent CLI."
---

Turn URLs, PDFs, Office files, HTML pages, data files, images, audio, ZIPs, and other documents into Markdown so they can be inspected, quoted, or summarized like normal text.

`markitdown` can fetch URLs by itself; this skill mainly wraps it to make saving + summarizing convenient.
For PDF inputs, use the `markitdown[pdf]` extra (or the wrapper below, which now does this automatically).

## When to use

Use this skill when you need to:
- pull down a web page as a document-like Markdown representation
- convert binary docs (PDF/DOCX/PPTX) into Markdown for analysis
- quickly produce a short summary of a long document before deeper work
- preserve a full converted Markdown artifact before extracting key points

## Quick usage

### Convert a URL or file to Markdown

Run from **this skill folder** (the agent should `cd` here first):

```bash
uvx --from 'markitdown[pdf]' markitdown <url-or-path>
```

Common formats:

- Documents: PDF, Word, PowerPoint, Excel, EPub
- Web/data: URL, HTML, CSV, JSON, XML
- Media: image EXIF/OCR, audio metadata/transcription where supported
- Archives: ZIP contents
- Video: YouTube URLs where supported by `markitdown`

To write Markdown to a temp file (prints the path) use the wrapper:

```bash
node to-markdown.mjs <url-or-path> --tmp
```

Tip: when summarizing, the script will **always** write the full converted Markdown to a temp `.md` file and will **always** print a final "Hint" line with the path (so you can open/inspect the full content).

Write Markdown to a specific file:

```bash
uvx --from 'markitdown[pdf]' markitdown <url-or-path> > /tmp/doc.md
```

Useful direct `markitdown` flags:

```bash
uvx --from 'markitdown[pdf]' markitdown input.docx -o output.md
uvx --from 'markitdown[pdf]' markitdown -x .pdf < input > output.md
uvx --from 'markitdown[pdf]' markitdown -m application/pdf input > output.md
uvx --from 'markitdown[pdf]' markitdown --list-plugins
```

For difficult scanned PDFs, consider Azure Document Intelligence only when configured:

```bash
uvx --from 'markitdown[pdf]' markitdown scan.pdf -d -e "https://<resource>.cognitiveservices.azure.com/"
```

### Convert + summarize (pass context!)

Summaries are only useful when you provide **what you want extracted** and the **audience/purpose**.

By default, summary mode auto-picks the first available CLI from `agent`, `pi`, then `claude`.

Set `AGENT_SUMMARIZER_CMD` to choose a harness-specific command. Examples:

```bash
AGENT_SUMMARIZER_CMD="pi --provider anthropic --model claude-haiku-4-5 --no-tools --no-session -p"
AGENT_SUMMARIZER_CMD="claude -p"
```

```bash
node to-markdown.mjs <url-or-path> --summary --prompt "Summarize focusing on X, for audience Y. Extract Z."
```

Or:

```bash
node to-markdown.mjs <url-or-path> --summary --prompt "Focus on security implications and action items."
```

This will:
1) convert to Markdown via `uvx --from 'markitdown[pdf]' markitdown`
2) write the full Markdown to a temp `.md` file and print its path as a "Hint" line
3) run the configured summarizer command using your extra prompt

## Notes

- First `uvx` run may cache dependencies.
- Prefer inspecting the saved Markdown when quoting exact wording.
- If extraction quality is poor, try direct `markitdown` flags before summarizing.
