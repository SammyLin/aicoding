# AI Development Standards

Standardized rules for AI coding agents with **progressive disclosure** — the agent gets what it needs, when it needs it.

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin

## Why Progressive Disclosure?

Loading 10+ rule files every session wastes context and dilutes attention.

```
❌ Old: 11 files always loaded → agent drowns in rules
✅ New: 3 core rules + auto-detected language + Skills on demand
```

| Layer | Mechanism | Loading | Files |
|-------|-----------|---------|-------|
| **Core** | `.claude/rules/` | Always | 3 (ai-behavior, code-quality, architecture) |
| **Language** | `.claude/rules/` | Always, auto-detected | 1-2 per project |
| **Skills** | `.claude/skills/` | Agent decides | 4 (security, ops, harness, browser) |

## How It Works

```
┌─────────── setup.sh ───────────┐
│                                │
│  1. Install core rules         │
│  2. Detect: go.mod? → lang-go  │
│     Detect: .tsx? → lang-frontend
│  3. Wrap situational rules     │
│     as Skills with descriptions│
└────────────┬───────────────────┘
             │
             ▼
  ┌── Your Project ──────────────┐
  │                              │
  │ .claude/rules/    (always)   │
  │   ai-behavior.md             │
  │   code-quality.md            │
  │   architecture.md            │
  │   lang-go.md      (detected) │
  │                              │
  │ .claude/skills/   (on demand)│
  │   security-check/SKILL.md    │
  │   infra-ops/SKILL.md         │
  │   harness-review/SKILL.md    │
  │   browser-verify/SKILL.md    │
  │                              │
  │ CLAUDE.md         (short map)│
  └──────────────────────────────┘
```

**Skills magic:** Claude sees skill descriptions (~250 chars each) in context. When the task matches — e.g., "add an API endpoint" matches security-check's description — Claude auto-loads the full skill content. No slash command needed.

## Quick Setup

```bash
# Claude Code (auto-detects project language)
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash

# Kiro
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro

# Both (symlinks, no duplication)
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all
```

### Auto-Detection

| File found | Language rule installed |
|------------|----------------------|
| `go.mod` | `lang-go.md` |
| `package.json` | `lang-node.md` |
| `pyproject.toml` or `requirements.txt` | `lang-python.md` |
| `.tsx` files, `vite.config.*`, or React in package.json | `lang-frontend.md` |
| None detected | All language rules installed |

## Standards

### Core Rules — always loaded

| File | Description |
|------|-------------|
| [ai-behavior.md](ai-behavior.md) | 5-step task flow, commit frequency, completion report |
| [code-quality.md](code-quality.md) | TDD, error handling, typing, API endpoint flow |
| [architecture.md](architecture.md) | Layered architecture, DI, module boundaries |

### Language Rules — auto-detected per project

| File | Language | Covers |
|------|----------|--------|
| [lang-node.md](lang-node.md) | Node / TypeScript | pnpm, ESLint, Prettier, Zod, vitest |
| [lang-python.md](lang-python.md) | Python | uv, ruff, FastAPI, Pydantic, pytest |
| [lang-go.md](lang-go.md) | Go | go mod, golangci-lint, table-driven tests |
| [lang-frontend.md](lang-frontend.md) | Frontend | React, component design, a11y |

### Skills — agent auto-invokes when relevant

| Skill | Source | When Claude uses it |
|-------|--------|-------------------|
| `security-check` | [security.md](security.md) | Adding API endpoints, shipping, handling user input |
| `infra-ops` | [project-ops.md](project-ops.md) | Docker, CI/CD, git workflow |
| `harness-review` | [harness-engineering.md](harness-engineering.md) | Recurring mistakes, systemic fixes |
| `browser-verify` | [agent-browser-skill.md](agent-browser-skill.md) | Frontend visual verification |

## Knowledge Base (`docs/`)

Articles about *how to use* AI coding agents effectively. Not installed into projects.

| Article | Topic |
|---------|-------|
| [逐步揭露.md](docs/逐步揭露.md) | Don't load everything at once |
| [context管理.md](docs/context管理.md) | Skills, memory, subagents, compaction |
| [agent-harness-基本原則.md](docs/agent-harness-基本原則.md) | 3 principles for agent systems |
| [我可以停掉什麼.md](docs/我可以停掉什麼.md) | Periodically review what's still needed |

## Update

```bash
./.aicoding-update.sh
```

## License

MIT
