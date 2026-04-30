import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join } from 'node:path';

export const LANGUAGES = ['node', 'python', 'go', 'frontend'] as const;
export type Language = (typeof LANGUAGES)[number];

// Parse a `--lang` CLI value (e.g. "node,python") into a typed list.
// Unknown values are dropped silently — runInit emits user-facing warnings.
export function parseLanguages(input: string): Language[] {
  const out: Language[] = [];
  for (const raw of input.split(',')) {
    const trimmed = raw.trim();
    if (trimmed && isLanguage(trimmed)) {
      out.push(trimmed);
    }
  }
  return out;
}

function isLanguage(value: string): value is Language {
  return (LANGUAGES as readonly string[]).includes(value);
}

const MARKER_MAX_DEPTH = 2;
const TSX_MAX_DEPTH = 4;

export function detectLanguages(cwd: string): Language[] {
  const detected: Language[] = [];

  if (findFile(cwd, 'package.json', MARKER_MAX_DEPTH)) {
    detected.push('node');
  }

  if (
    findFile(cwd, 'pyproject.toml', MARKER_MAX_DEPTH) ||
    findFile(cwd, 'requirements.txt', MARKER_MAX_DEPTH)
  ) {
    detected.push('python');
  }

  if (findFile(cwd, 'go.mod', MARKER_MAX_DEPTH)) {
    detected.push('go');
  }

  if (isFrontend(cwd)) {
    detected.push('frontend');
  }

  return detected;
}

function isFrontend(cwd: string): boolean {
  if (findFileSuffix(cwd, '.tsx', TSX_MAX_DEPTH)) return true;
  if (existsAtRoot(cwd, ['vite.config.ts', 'vite.config.js', 'next.config.js', 'next.config.ts'])) {
    return true;
  }
  return packageJsonMentions(cwd, 'react');
}

function existsAtRoot(cwd: string, names: string[]): boolean {
  return names.some((name) => {
    try {
      statSync(join(cwd, name));
      return true;
    } catch {
      return false;
    }
  });
}

function packageJsonMentions(cwd: string, needle: string): boolean {
  try {
    const contents = readFileSync(join(cwd, 'package.json'), 'utf8');
    return contents.includes(`"${needle}"`);
  } catch {
    return false;
  }
}

function findFile(cwd: string, name: string, maxDepth: number): boolean {
  return walk(cwd, maxDepth, (entryName, isDir) => !isDir && entryName === name);
}

function findFileSuffix(cwd: string, suffix: string, maxDepth: number): boolean {
  return walk(cwd, maxDepth, (entryName, isDir) => !isDir && entryName.endsWith(suffix));
}

function walk(
  dir: string,
  maxDepth: number,
  match: (name: string, isDir: boolean) => boolean,
  depth = 1,
): boolean {
  let entries;
  try {
    entries = readdirSync(dir, { withFileTypes: true });
  } catch {
    return false;
  }
  for (const entry of entries) {
    const isDir = entry.isDirectory();
    if (match(entry.name, isDir)) return true;
    if (isDir && depth < maxDepth) {
      if (walk(join(dir, entry.name), maxDepth, match, depth + 1)) return true;
    }
  }
  return false;
}
