import type { Language } from './detect.js';

export const CORE_FILES = [
  'ai-behavior.md',
  'code-quality.md',
  'architecture.md',
  'prp-template.md',
] as const;

export interface LangManifestEntry {
  language: Language;
  file: string;
  label: string;
  // Kiro accepts a single glob or a list. We always emit a list so multiple
  // patterns OR together correctly — the older `|`-joined string was treated
  // as one literal glob and never matched anything.
  kiroPattern: string[];
}

export const LANG_MANIFEST: ReadonlyArray<LangManifestEntry> = [
  {
    language: 'node',
    file: 'lang-node.md',
    label: 'Node/TypeScript',
    kiroPattern: [
      '**/*.ts',
      '**/*.js',
      '**/*.mjs',
      '**/*.cjs',
      'package.json',
      'tsconfig.json',
      'pnpm-lock.yaml',
    ],
  },
  {
    language: 'python',
    file: 'lang-python.md',
    label: 'Python',
    kiroPattern: ['**/*.py', 'pyproject.toml', 'requirements.txt', 'uv.lock'],
  },
  {
    language: 'go',
    file: 'lang-go.md',
    label: 'Go',
    kiroPattern: ['**/*.go', 'go.mod', 'go.sum'],
  },
  {
    language: 'frontend',
    file: 'lang-frontend.md',
    label: 'Frontend (React)',
    kiroPattern: [
      '**/*.tsx',
      '**/*.jsx',
      '**/*.css',
      '**/*.scss',
      'vite.config.*',
      'next.config.*',
    ],
  },
];

export interface SkillManifestEntry {
  name: string;
  source: string;
  description: string;
}

export const SKILLS: ReadonlyArray<SkillManifestEntry> = [
  {
    name: 'security-check',
    source: 'security.md',
    description:
      '10-item security checklist. Use before adding API endpoints, shipping code, or handling user input. Covers secrets, SQL injection, XSS, auth, HTTPS.',
  },
  {
    name: 'infra-ops',
    source: 'project-ops.md',
    description:
      'Docker, git workflow, CI/CD, observability standards. Use when setting up infrastructure, writing Dockerfiles, or configuring deployment.',
  },
  {
    name: 'harness-review',
    source: 'harness-engineering.md',
    description:
      'Guardrails and feedback loops. Use when a mistake recurs, when fixing systemic issues, or when strengthening the development harness.',
  },
  {
    name: 'browser-verify',
    source: 'agent-browser-skill.md',
    description:
      'agent-browser CLI for frontend verification. Use when you need to visually verify frontend changes in a real browser.',
  },
];

export const AGENT_FILES = ['agents/code-reviewer.md'] as const;
export const COMMAND_FILES = ['commands/commit.md', 'commands/review.md'] as const;
export const HOOK_FILES = ['hooks/auto-format.sh', 'hooks/secret-guard.sh'] as const;
