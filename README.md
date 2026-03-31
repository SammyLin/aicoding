# AI Development Standards v4.4

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin | **Last Updated:** 2026-03-30

## Quick Setup

在專案根目錄執行一行指令即可安裝標準：

### Claude Code

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
```

產生的結構：

```
CLAUDE.md                          ← 短目錄檔 (<200 行)
.claude/rules/
├── code-quality.md
├── architecture.md
├── security.md
├── project-ops.md
├── ai-behavior.md
└── harness-engineering.md
```

### Kiro

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
```

產生的結構：

```
.kiro/steering/
├── standards.md                   ← 短目錄檔
├── code-quality.md
├── architecture.md
├── security.md
├── project-ops.md
├── ai-behavior.md
└── harness-engineering.md
```

### Both (Claude Code + Kiro)

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all
```

## Standards

| File | Description |
|------|-------------|
| [code-quality.md](code-quality.md) | Code quality, testing, error handling, typing |
| [architecture.md](architecture.md) | Layered architecture, DI, module boundaries |
| [security.md](security.md) | Secrets, input validation, MCP server rules |
| [project-ops.md](project-ops.md) | Project structure, git, CI/CD, observability |
| [ai-behavior.md](ai-behavior.md) | AI agent behavior rules and quick reference |
| [harness-engineering.md](harness-engineering.md) | Harness engineering: docs structure, guardrails, feedback loops |

## How It Works

1. `cd` into your project root
2. Run the one-liner for your tool (Claude Code / Kiro / Both)
3. Standards are downloaded and structured into the correct config files
4. Open your AI tool — it automatically reads the standards and applies them
5. Re-run anytime to update to the latest version

## License

MIT
