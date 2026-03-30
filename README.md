# AI Development Standards v4.2

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Maintainer:** Sammy Lin | **Last Updated:** 2026-03-30

## Onboarding Prompt

在任何 AI coding tool（Claude Code、Kiro、Cursor、Windsurf…）的新專案中貼上這段 prompt，AI 就會自動讀取 standards 並設定到專案裡：

```
讀取以下檔案，作為這個專案的開發標準：

- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/code-quality.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/architecture.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/security.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/project-ops.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/ai-behavior.md

然後根據你目前運行的工具，自動建立對應的設定檔：

- Claude Code → 建立 CLAUDE.md，寫入 standards 內容
- Kiro → 建立 .kiro/steering/standards.md，寫入 standards 內容
- Cursor → 建立 .cursorrules，寫入 standards 內容
- Windsurf → 建立 .windsurfrules，寫入 standards 內容
- 其他工具 → 建立該工具的對應設定檔

設定檔內容格式：
1. 在檔案開頭標註 source: https://github.com/SammyLin/aicoding
2. 將所有 standards 整合寫入，保留原始結構
3. 如果專案已有設定檔，將 standards 追加到現有內容之後

完成後回覆你建立了哪些檔案。
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
