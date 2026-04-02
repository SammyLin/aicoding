# AI Development Standards

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    aicoding (GitHub repo)                        │
│                                                                 │
│  code-quality.md   architecture.md   security.md                │
│  project-ops.md    ai-behavior.md    harness-engineering.md     │
│                          │                                      │
│                      setup.sh                                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
              curl ... setup.sh | bash
                           │
           ┌───────────────┼───────────────────────────┐
           │               │                           │
           ▼               ▼                           ▼
    ┌─── Claude Code ───┐  │  ┌───── Kiro ────────┐  ┌─── Skill ──────────┐
    │                    │  │  │                    │  │                    │
    │ CLAUDE.md          │  │  │ .kiro/steering/    │  │ .claude/skills/    │
    │   (entry file,     │  │  │   standards.md     │  │   aicoding-        │
    │    auto-loaded)    │  │  │   (entry file,     │  │   standards.md     │
    │                    │  │  │    auto-loaded)     │  │   (skill entry)    │
    │ .claude/rules/     │  │  │                    │  │                    │
    │   code-quality.md  │  │  │   code-quality.md  │  │   code-quality.md  │
    │   architecture.md  │  │  │   architecture.md  │  │   architecture.md  │
    │   security.md      │  │  │   security.md      │  │   security.md      │
    │   project-ops.md   │  │  │   project-ops.md   │  │   project-ops.md   │
    │   ai-behavior.md   │  │  │   ai-behavior.md   │  │   ai-behavior.md   │
    │   harness-eng...md │  │  │   harness-eng...md │  │   harness-eng...md │
    │                    │  │  │                    │  │                    │
    │ ALL auto-loaded    │  │  │ ALL auto-loaded    │  │ On-demand skills   │
    │ at session start   │  │  │ at session start   │  │ invoked by agent   │
    └────────────────────┘  │  └────────────────────┘  └────────────────────┘
                            │
                   ┌────────┴────────┐
                   │   AI Agent      │
                   │   reads rules   │
                   │   and follows   │
                   │   step-by-step  │
                   │   workflows     │
                   └─────────────────┘
```

### How auto-loading works

| Tool | Entry File | Rules Directory | Loading |
|------|-----------|----------------|---------|
| Claude Code | `CLAUDE.md` | `.claude/rules/*.md` | All loaded at session start automatically |
| Kiro | `.kiro/steering/standards.md` | `.kiro/steering/*.md` | All `always` inclusion files loaded automatically |
| Skill | `.claude/skills/aicoding-standards.md` | `.claude/skills/*.md` | On-demand, invoked as skills by the agent |

The AI agent does NOT need to manually read these files — they are injected into context at session start.

## Quick Setup

Run one command in your project root:

### Claude Code

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
```

### Kiro

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
```

### Skill (Claude Code skills)

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --skill
```

### All (Claude Code + Kiro + Skill)

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all
```

> **Note:** When using `--all`, rule files are downloaded once to `.claude/rules/` and symbolic links are created in `.kiro/steering/` and `.claude/skills/` pointing to them — no duplicate files.

## Standards

### Core Rules (language-agnostic, always loaded)

| File | Description |
|------|-------------|
| [code-quality.md](code-quality.md) | TDD workflow, API endpoint flow, error handling, typing |
| [architecture.md](architecture.md) | Layered architecture, DI, new feature module step-by-step |
| [security.md](security.md) | Security checklist (10 items), MCP server rules |
| [project-ops.md](project-ops.md) | Docker-first development, new project setup, git, CI/CD |
| [ai-behavior.md](ai-behavior.md) | 5-step task execution flow, completion report format |
| [harness-engineering.md](harness-engineering.md) | Browser verification, feedback loops, docs structure, guardrails |

### Language-Specific Rules (apply based on project language)

| File | Language | Covers |
|------|----------|--------|
| [lang-node.md](lang-node.md) | Node / TypeScript | pnpm, ESLint + Prettier, Zod, vitest, Dockerfile |
| [lang-python.md](lang-python.md) | Python | uv, ruff, FastAPI, Pydantic, pytest, Dockerfile |
| [lang-go.md](lang-go.md) | Go | go mod, golangci-lint, constructor DI, table-driven tests, Dockerfile |
| [lang-frontend.md](lang-frontend.md) | Frontend | React, component design, state management, a11y, testing-library |

## Generated File References

### CLAUDE.md (generated by setup.sh)

```markdown
# aicoding standards
# source: https://github.com/SammyLin/aicoding

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Standards (auto-loaded from .claude/rules/)

The following rules are automatically loaded into your context at session start.
You do NOT need to read them manually — they are already available to you.

- **code-quality**: Code quality, testing, error handling, typing
- **architecture**: Layered architecture, DI, module boundaries
- **security**: Secrets, input validation, MCP server rules
- **project-ops**: Project structure, git, CI/CD, observability
- **ai-behavior**: AI agent behavior rules and quick reference
- **harness-engineering**: Harness engineering: docs structure, guardrails, feedback loops

## When to Apply Which Rules

| Task | Primary Rules | Key Actions |
|------|--------------|-------------|
| **Any task** | ai-behavior | Follow 5-step flow: Research → Plan → Implement → Verify → Report |
| **Write backend code** | code-quality, architecture, lang-* | TDD flow, layered architecture, DI, typed interfaces |
| **Add new feature module** | architecture, lang-* | Create files in order: model → repo → service → handler → test |
| **Add API endpoint** | code-quality, lang-*, security | Follow API endpoint flow, validate input, check security checklist |
| **Frontend changes** | lang-frontend, harness-engineering, code-quality | Feature-based structure, component design, a11y, browser screenshot verification |
| **New project setup** | project-ops | Docker-first: Dockerfile → docker-compose.yml → Makefile → linter setup → /health |
| **Fix a bug** | code-quality, ai-behavior | Write failing test first, fix, verify, report |
| **Security review** | security | Run 10-item security checklist before completion |
| **Refactor / cleanup** | architecture, harness-engineering | Structural tests, no layer violations, strengthen harness |
| **Write tests** | code-quality | TDD steps, mock externals, descriptive names, run in Docker |
| **Docker / infra** | project-ops | Multi-stage build, non-root, healthcheck, pin versions |

## Task Execution Flow

1. Research: read related source files to understand existing patterns
2. Plan: list files to change, confirm with user if >3 files
3. Implement: one feature at a time, TDD (test first → implement → verify)
4. Verify: run tests + lint inside Docker, screenshot for frontend
5. Report: use the completion report format from ai-behavior rules
```

### .kiro/steering/standards.md (generated by setup.sh)

```markdown
---
inclusion: always
---
# aicoding standards
# source: https://github.com/SammyLin/aicoding

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Standards (auto-loaded from .kiro/steering/)

The following steering files are automatically loaded into your context.
You do NOT need to read them manually — they are already available to you.

- **code-quality**: Code quality, testing, error handling, typing
- **architecture**: Layered architecture, DI, module boundaries
- **security**: Secrets, input validation, MCP server rules
- **project-ops**: Project structure, git, CI/CD, observability
- **ai-behavior**: AI agent behavior rules and quick reference
- **harness-engineering**: Harness engineering: docs structure, guardrails, feedback loops

## When to Apply Which Rules

| Task | Primary Rules | Key Actions |
|------|--------------|-------------|
| **Any task** | ai-behavior | Follow 5-step flow: Research → Plan → Implement → Verify → Report |
| **Write backend code** | code-quality, architecture, lang-* | TDD flow, layered architecture, DI, typed interfaces |
| **Add new feature module** | architecture, lang-* | Create files in order: model → repo → service → handler → test |
| **Add API endpoint** | code-quality, lang-*, security | Follow API endpoint flow, validate input, check security checklist |
| **Frontend changes** | lang-frontend, harness-engineering, code-quality | Feature-based structure, component design, a11y, browser screenshot verification |
| **New project setup** | project-ops | Docker-first: Dockerfile → docker-compose.yml → Makefile → linter setup → /health |
| **Fix a bug** | code-quality, ai-behavior | Write failing test first, fix, verify, report |
| **Security review** | security | Run 10-item security checklist before completion |
| **Refactor / cleanup** | architecture, harness-engineering | Structural tests, no layer violations, strengthen harness |
| **Write tests** | code-quality | TDD steps, mock externals, descriptive names, run in Docker |
| **Docker / infra** | project-ops | Multi-stage build, non-root, healthcheck, pin versions |

## Task Execution Flow

1. Research: read related source files to understand existing patterns
2. Plan: list files to change, confirm with user if >3 files
3. Implement: one feature at a time, TDD (test first → implement → verify)
4. Verify: run tests + lint inside Docker, screenshot for frontend
5. Report: use the completion report format from ai-behavior rules
```

## How It Works

1. `cd` into your project root
2. Run the one-liner for your tool (Claude Code / Kiro / Both)
3. Standards are downloaded into the tool's config directory
4. Open your AI tool — it **automatically** reads all standards at session start

## Update

After initial setup, a `.aicoding-update.sh` script is generated in your project root. To update to the latest standards:

```bash
./.aicoding-update.sh
```

This re-downloads all rule files and regenerates entry files. No need to remember the original curl command.

## License

MIT
