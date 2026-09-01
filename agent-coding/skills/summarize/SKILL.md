---
name: summarize
description: "Convert URLs and document files to inspectable Markdown with `markitdown` before analyzing or summarizing them in the current conversation."
---

# Summarize

Convert document-like inputs to Markdown, then inspect or summarize them in the
current conversation. Do not launch another agent, select another model, or
forward a generic summary prompt: keeping the work here preserves the user's
actual request and conversation context.

## Workflow

For a quick conversion:

```sh
uvx --from 'markitdown[pdf]' markitdown <url-or-path>
```

For a long or binary input, save an inspectable temporary Markdown file:

Run these wrapper commands from this skill directory:

```sh
node to-markdown.mjs <url-or-path> --tmp
```

For a stable output path:

```sh
node to-markdown.mjs <url-or-path> --out <file.md>
```

Then read the relevant Markdown and answer the user's actual question. Preserve
headings, names, quantities, and uncertainty when they matter. Use targeted
searches or chunks for large documents instead of loading an entire conversion
when only a small section is relevant.

## PDF boundary

- Use Markdown extraction for text-first reading, search, quotation, and
  section-level analysis.
- When layout, charts, handwriting, scans, or page geometry matter, inspect the
  original PDF or rendered page images as well. Text extraction alone is not
  evidence about visual layout.
- MarkItDown does not guarantee page anchors. When page citations matter, use a
  page-aware extractor or render pages separately, retain the page mapping, and
  inspect the cited pages before making layout-sensitive claims.

`markitdown` supports common PDFs, Office documents, HTML, data files, images,
audio, archives, and URLs. Conversion quality varies; inspect the source when
exact wording or structure matters.
