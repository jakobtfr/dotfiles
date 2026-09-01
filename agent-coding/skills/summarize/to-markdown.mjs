#!/usr/bin/env node
/**
 * Convert a URL or local file to Markdown using `uvx markitdown`.
 * The current agent can then inspect or summarize the Markdown without losing
 * the user's conversation context to a separate summarizer process.
 *
 * Usage:
 *   node to-markdown.mjs <url-or-path> [--out <file> | --tmp]
 *
 * Examples:
 *   node to-markdown.mjs https://example.com
 *   node to-markdown.mjs ./spec.pdf --tmp
 */

import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { basename, join } from 'path';
import { tmpdir } from 'os';
import { spawnSync } from 'child_process';

const argv = process.argv.slice(2);

function usageAndExit(code = 1) {
  const out = code === 0 ? console.log : console.error;
  out('Usage: node to-markdown.mjs <url-or-path> [--out <file> | --tmp]');
  process.exit(code);
}

function isFlag(s) {
  return typeof s === 'string' && s.startsWith('--');
}

function isUrl(s) {
  return /^https?:\/\//i.test(s);
}

function ensureDir(path) {
  mkdirSync(path, { recursive: true });
}

function safeName(s) {
  return (s || 'document').replace(/[^a-z0-9._-]+/gi, '_');
}

function getInputBasename(s) {
  if (isUrl(s)) {
    const u = new URL(s);
    const b = basename(u.pathname);
    return safeName(b || 'document');
  }
  return safeName(basename(s));
}

function makeTmpMdPath(input) {
  const dir = join(tmpdir(), 'agent-summarize-out');
  ensureDir(dir);
  const base = getInputBasename(input);
  const stamp = Date.now().toString(36);
  const rand = Math.random().toString(16).slice(2, 8);
  return join(dir, `${base}-${stamp}-${rand}.md`);
}

// --- args parsing ---
let input = null;
let outPath = null;
let writeTmp = false;

for (let i = 0; i < argv.length; i++) {
  const a = argv[i];

  if (a === '--help' || a === '-h') {
    usageAndExit(0);
  }

  if (a === '--out') {
    outPath = argv[i + 1] ?? null;
    if (!outPath || isFlag(outPath)) {
      console.error('Expected a value after --out');
      process.exit(1);
    }
    i++;
    continue;
  }

  if (a === '--tmp') {
    writeTmp = true;
    continue;
  }

  if (isFlag(a)) {
    console.error(`Unknown flag: ${a}`);
    usageAndExit(1);
  }

  if (!input) {
    input = a;
  } else {
    console.error(`Unexpected argument: ${a}`);
    usageAndExit(1);
  }
}

if (!input) usageAndExit(1);
if (outPath && writeTmp) {
  console.error('--out and --tmp are mutually exclusive');
  usageAndExit(1);
}

function runMarkitdown(arg) {
  // Include PDF support by default because many document URLs (for example arXiv PDFs)
  // are detected as PDFs only after fetching, so extension-based switching is unreliable.
  const result = spawnSync('uvx', ['--from', 'markitdown[pdf]', 'markitdown', arg], {
    encoding: 'utf-8',
    maxBuffer: 50 * 1024 * 1024
  });

  if (result.error) {
    throw new Error(`Failed to run uvx markitdown: ${result.error.message}`);
  }
  if (result.status !== 0) {
    const stderr = (result.stderr || '').trim();
    throw new Error(`markitdown failed for ${arg}${stderr ? `\n${stderr}` : ''}`);
  }
  return result.stdout;
}

async function main() {
  if (!isUrl(input) && !existsSync(input)) {
    throw new Error(`File not found: ${input}`);
  }

  const md = runMarkitdown(input);

  if (outPath) {
    writeFileSync(outPath, md, 'utf-8');
    console.log(outPath);
    return;
  }

  if (writeTmp) {
    const tmpMdPath = makeTmpMdPath(input);
    writeFileSync(tmpMdPath, md, 'utf-8');
    console.log(tmpMdPath);
    return;
  }

  process.stdout.write(md);
}

main().catch(err => {
  console.error(err?.message || String(err));
  process.exit(1);
});
