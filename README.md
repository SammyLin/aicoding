# AI Development Standards

> [繁體中文](README.zh-TW.md)

**Team AI-coding standards for bootstrapping new projects**, installed into Claude Code or Kiro CLI with progressive disclosure — only what's needed, only when it's needed.

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin

## Why this repo exists

When a team starts a new project, every member's AI-agent setup differs, leading to:

- Inconsistent code style
- Some run lint, some don't
- `.env` accidentally pulled into context
- Commit messages all over the place

This repo codifies the team's best practices into a one-command installer.

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
```

## What gets installed (Claude Code)

```
.claude/
├── rules/                    ← rules (auto-loaded by Claude)
│   ├── ai-behavior.md           core: 5-step flow, commit frequency
│   ├── code-quality.md          core: TDD, error handling, typing
│   ├── architecture.md          core: layered architecture, DI
│   └── lang-go.md               language: detected per project; paths: scope
├── skills/                   ← skills (agent-invoked on demand)
│   ├── security-check/          new API, shipping, user input
│   ├── infra-ops/               Docker, CI/CD, git workflow
│   ├── harness-review/          systemic improvements
│   └── browser-verify/          frontend visual verification
├── agents/
│   └── code-reviewer.md      ← subagent: structured review of changes
├── commands/
│   ├── commit.md             ← /commit: lint + test + conventional message
│   └── review.md             ← /review: invokes code-reviewer
├── hooks/
│   ├── auto-format.sh        ← PostToolUse: auto-format after edits
│   └── secret-guard.sh       ← PreToolUse Bash: blocks .env, rm -rf, curl | sh
└── settings.json             ← team permissions + hook wiring
CLAUDE.md                     ← main file (short, @imports rules)
```

## 5-Layer Architecture

| Layer | Location | When Loaded | Content |
|-------|----------|-------------|---------|
| **Core** | `.claude/rules/` | Always | Needed for every task |
| **Language** | `.claude/rules/` | When `paths:` match | Language-specific conventions |
| **Skills** | `.claude/skills/` | Claude decides | Security, ops, harness, browser |
| **Agent + Commands** | `.claude/agents/` + `.claude/commands/` | User invokes | Verify / Commit flow |
| **Hooks + Settings** | `.claude/hooks/` + `.claude/settings.json` | Event-triggered | Auto-format, block risky commands |

### How the 5-step flow is supported by tooling

| Step | Tool |
|------|------|
| 1. Research | Claude Code's built-in Explore subagent |
| 2. Plan | Claude Code's built-in Plan subagent |
| 3. Implement | Main conversation + `auto-format` hook cleans up after every edit |
| 4. **Verify** | `/review` → `code-reviewer` subagent does an independent pass |
| 5. **Commit** | `/commit` → lint + test + conventional commit message |

## Install

```bash
# Claude Code (auto-detects project language)
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash

# Kiro CLI
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro

# Both
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all
```

### Language auto-detection

| Detected | Installs |
|----------|----------|
| `go.mod` | `lang-go.md` |
| `package.json` | `lang-node.md` |
| `pyproject.toml` / `requirements.txt` | `lang-python.md` |
| `.tsx` / `vite.config.*` / React | `lang-frontend.md` |
| None | All of the above |

## Kiro CLI differences

Kiro CLI's design model doesn't fully overlap with Claude Code. Mapping:

| Claude Code | Kiro CLI | Status |
|-------------|----------|--------|
| Rules (`paths:`) | Steering (`inclusion: fileMatch` + `fileMatchPattern`) | ✅ auto-converted |
| Skills | Steering `inclusion: manual` | ✅ installed under `on-demand/` |
| Agents (markdown) | Agents (**JSON**) | ✅ format auto-converted |
| Commands (`/commit`) | — | ❌ Kiro CLI has no equivalent |
| Hooks | Hooks (different events) | ❌ model too different — not installed |
| `settings.json` (project-level) | Machine-level settings | ❌ not a project-shared concern |

## Standard Contents

### Core Rules — always loaded

| File | Content |
|------|---------|
| [rules/ai-behavior.md](rules/ai-behavior.md) | 5-step flow, commit frequency, completion report |
| [rules/code-quality.md](rules/code-quality.md) | TDD, error handling, typing, API endpoint flow |
| [rules/architecture.md](rules/architecture.md) | Layered architecture, DI, module boundaries |

### Language Rules — installed when detected

| File | Language | Covers |
|------|----------|--------|
| [rules/lang-node.md](rules/lang-node.md) | Node / TypeScript | pnpm, ESLint, Prettier, Zod, vitest |
| [rules/lang-python.md](rules/lang-python.md) | Python | uv, ruff, FastAPI, Pydantic, pytest |
| [rules/lang-go.md](rules/lang-go.md) | Go | go mod, golangci-lint, table-driven tests |
| [rules/lang-frontend.md](rules/lang-frontend.md) | Frontend | React, component design, a11y |

### Skills — agent-invoked on demand

| Skill | Source | Trigger |
|-------|--------|---------|
| `security-check` | [skills/security.md](skills/security.md) | adding APIs, shipping, handling user input |
| `infra-ops` | [skills/project-ops.md](skills/project-ops.md) | Docker, CI/CD, git workflow |
| `harness-review` | [skills/harness-engineering.md](skills/harness-engineering.md) | systemic improvements |
| `browser-verify` | [skills/agent-browser-skill.md](skills/agent-browser-skill.md) | frontend visual verification |

### Agent + Commands — supporting Verify / Commit

| File | Purpose |
|------|---------|
| [agents/code-reviewer.md](agents/code-reviewer.md) | Subagent: structured review of changes (Must Fix / Should Consider / OK) |
| [commands/commit.md](commands/commit.md) | `/commit`: lint + test + conventional commit message |
| [commands/review.md](commands/review.md) | `/review`: invoke the code-reviewer subagent |

### Hooks + Settings

| File | Trigger | Action |
|------|---------|--------|
| [hooks/auto-format.sh](hooks/auto-format.sh) | `PostToolUse` Edit/Write | Run gofmt / ruff / prettier by extension (silent on failure) |
| [hooks/secret-guard.sh](hooks/secret-guard.sh) | `PreToolUse` Bash | Block `.env`, `rm -rf`, `curl \| sh`, SSH keys |
| [settings.json](settings.json) | — | Team-default permissions + hook wiring (installed as `.claude/settings.json`) |

## Update

```bash
./.aicoding-update.sh
```

## Knowledge Base (`docs/`)

Articles explaining the design rationale. **Not** installed into target projects.

| Article | Topic |
|---------|-------|
| [逐步揭露.md](docs/逐步揭露.md) | Why you shouldn't stuff everything into context at once |
| [context管理.md](docs/context管理.md) | Skills, memory, subagents, compaction |
| [agent-harness-基本原則.md](docs/agent-harness-基本原則.md) | Three principles for agent systems |
| [我可以停掉什麼.md](docs/我可以停掉什麼.md) | Periodically review what's still needed |
| [使用指南.md](docs/使用指南.md) | Team usage guide (onboarding, daily workflow, troubleshooting) |
| [github調查報告-dotclaude結構.md](docs/github調查報告-dotclaude結構.md) | GitHub survey of `.claude/` conventions |

## Contributing: Language Policy

- **AI-facing files** (rules, skills, agents, commands, hooks, `CLAUDE.md`) are written in **English**.
- **Human-facing docs** (`docs/`, this README) may be bilingual.
- **When editing README, update both `README.md` and [`README.zh-TW.md`](README.zh-TW.md)** — they must stay in sync.

## License

MIT
