# AI Development Standards v4.2

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Maintainer:** Sammy Lin | **Last Updated:** 2026-03-30

## Setup by Tool

### Claude Code

在專案根目錄的 `CLAUDE.md` 加入：

```markdown
## Standards

Read and follow the AI development standards at:
https://github.com/SammyLin/aicoding

Before starting any task, fetch and apply these files:
- code-quality.md — coding style, testing, error handling
- architecture.md — layered architecture, DI, module boundaries
- security.md — secrets, input validation
- project-ops.md — git workflow, CI/CD, project structure
- ai-behavior.md — agent behavior rules
```

### Kiro

在 `.kiro/steering/` 目錄下建立 `standards.md`：

```markdown
## Standards

Read and follow the AI development standards at:
https://github.com/SammyLin/aicoding

Before starting any task, fetch and apply these files:
- code-quality.md — coding style, testing, error handling
- architecture.md — layered architecture, DI, module boundaries
- security.md — secrets, input validation
- project-ops.md — git workflow, CI/CD, project structure
- ai-behavior.md — agent behavior rules
```

### Cursor / Windsurf

在專案根目錄的 `.cursorrules` 或 `.windsurfrules` 加入：

```markdown
## Standards

Read and follow the AI development standards at:
https://github.com/SammyLin/aicoding

Before starting any task, fetch and apply these files:
- code-quality.md — coding style, testing, error handling
- architecture.md — layered architecture, DI, module boundaries
- security.md — secrets, input validation
- project-ops.md — git workflow, CI/CD, project structure
- ai-behavior.md — agent behavior rules
```

### 通用 Prompt（任何 AI agent）

直接在對話開頭貼：

```
你是這個專案的 AI coding agent。開始工作前，先讀取以下標準並嚴格遵守：
https://raw.githubusercontent.com/SammyLin/aicoding/main/code-quality.md
https://raw.githubusercontent.com/SammyLin/aicoding/main/architecture.md
https://raw.githubusercontent.com/SammyLin/aicoding/main/security.md
https://raw.githubusercontent.com/SammyLin/aicoding/main/project-ops.md
https://raw.githubusercontent.com/SammyLin/aicoding/main/ai-behavior.md

讀完後回覆「Standards loaded」，然後等待我的指令。
```

## Standards

| File | Description |
|------|-------------|
| [code-quality.md](code-quality.md) | Code quality, testing, error handling, typing |
| [architecture.md](architecture.md) | Layered architecture, DI, module boundaries |
| [security.md](security.md) | Secrets, input validation, MCP server rules |
| [project-ops.md](project-ops.md) | Project structure, git, CI/CD, observability |
| [ai-behavior.md](ai-behavior.md) | AI agent behavior rules and quick reference |

## How It Works

1. AI agent reads these files at session start
2. Rules are applied as constraints during code generation
3. Agent follows verification sequence after each implementation

## License

MIT
