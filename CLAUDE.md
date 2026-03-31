# aicoding repo

This repo provides standardized AI coding rules. It is NOT a software project — it is a collection of markdown standards and a setup script that installs them into other projects.

## Repo Structure

```
*.md          — Standard rule files (downloaded by setup.sh into target projects)
lang-*.md     — Language-specific rules (node, python, go, frontend)
setup.sh      — Installer script: downloads rules + generates entry files (CLAUDE.md, .kiro/steering/)
README.md     — Documentation for users of this repo
```

## Key Concepts

- **Core rules** (always installed): code-quality, architecture, security, project-ops, ai-behavior, harness-engineering
- **Language rules** (also installed, applied per project): lang-node, lang-python, lang-go, lang-frontend
- `setup.sh` downloads all rule files into `.claude/rules/` or `.kiro/steering/` and generates an entry file
- The `--all` flag uses symlinks from `.kiro/steering/` to `.claude/rules/` to avoid duplication

## When Editing Standards

- Each rule file is self-contained — no cross-file imports or references needed
- Keep rules actionable and concise; avoid vague guidance
- Use tables and numbered steps for clarity
- If adding a new rule file: add it to both `FILES` and `DESCRIPTIONS` arrays in `setup.sh`
- If renaming/removing a file: update `setup.sh` arrays, README.md, and the generated entry file templates inside `setup.sh`

## When Editing setup.sh

- The script generates three things: rule files in target dir, entry file (CLAUDE.md or standards.md), and `.aicoding-update.sh`
- The `--all` mode downloads once to `.claude/rules/` then symlinks to `.kiro/steering/`
- Test changes by running: `bash setup.sh` (Claude Code mode), `bash setup.sh --kiro`, `bash setup.sh --all`
- The generated CLAUDE.md template is embedded in `generate_claude_md()` — keep it in sync with `generate_kiro_steering()`

## Conventions

- No build tools, no dependencies, no package manager — just markdown + bash
- README.md contains the "Generated File References" section showing what setup.sh produces — keep it in sync
- MIT licensed
