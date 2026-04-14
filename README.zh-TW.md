# AI Development Standards

> [English](README.md)

**團隊起新系統時的 AI 編碼標準**，使用 progressive disclosure 安裝到 Claude Code 或 Kiro CLI — 該載的才載，該觸發的才觸發。

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin

## 為什麼要有這個 repo

團隊起新系統時，每個成員的 AI agent 設定不一樣，導致：

- 程式風格不一致
- 有人跑 lint 有人不跑
- `.env` 會被不小心讀進 context
- commit message 各寫各的

這個 repo 把團隊的最佳實踐固化成**一條指令就能裝起來**的標準配置。

```bash
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
```

## 裝了什麼？（Claude Code）

```
.claude/
├── rules/                    ← 規則（Claude 自動載入）
│   ├── ai-behavior.md           核心：5 步驟 flow、commit 頻率
│   ├── code-quality.md          核心：TDD、錯誤處理、typing
│   ├── architecture.md          核心：分層架構、DI
│   └── lang-go.md               語言：依偵測結果裝，paths: 限定只在 Go 檔案載入
├── skills/                   ← 技能（Claude 按需呼叫）
│   ├── security-check/          新增 API、上線前、處理使用者輸入
│   ├── infra-ops/               Docker、CI/CD、git workflow
│   ├── harness-review/          系統性改進
│   └── browser-verify/          前端視覺驗證
├── agents/
│   └── code-reviewer.md      ← Subagent：結構化審查變更
├── commands/
│   ├── commit.md             ← /commit 指令：lint + test + 產生規範化訊息
│   └── review.md             ← /review 指令：呼叫 code-reviewer
├── hooks/
│   ├── auto-format.sh        ← PostToolUse：改完檔自動 format
│   └── secret-guard.sh       ← PreToolUse Bash：擋 .env、rm -rf、curl | sh
└── settings.json             ← 團隊權限 + hooks 掛載
CLAUDE.md                     ← 主檔（短，用 @import 引入規則）
```

## 5 層架構

| 層 | 位置 | 載入時機 | 內容 |
|----|------|---------|------|
| **Core** | `.claude/rules/` | 永遠 | 每個任務都需要 |
| **Language** | `.claude/rules/` | 檔案符合 `paths:` 時 | 語言特定慣例 |
| **Skills** | `.claude/skills/` | Claude 判斷需要時 | 安全、ops、harness、browser |
| **Agent + Commands** | `.claude/agents/` + `.claude/commands/` | 使用者呼叫時 | Verify / Commit 流程 |
| **Hooks + Settings** | `.claude/hooks/` + `.claude/settings.json` | 事件觸發 | 自動 format、擋危險指令 |

### 5 步驟 flow 如何被工具支撐

| 步驟 | 工具 |
|------|------|
| 1. Research | Claude Code 內建 Explore subagent |
| 2. Plan | Claude Code 內建 Plan subagent |
| 3. Implement | 主對話 + `auto-format` hook 自動整理 |
| 4. **Verify** | `/review` → `code-reviewer` subagent 獨立審查 |
| 5. **Commit** | `/commit` → lint + test + 規範化 commit message |

## 安裝

```bash
# Claude Code（自動偵測專案語言）
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash

# Kiro CLI
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro

# 兩個都裝
curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all
```

### 語言自動偵測

| 偵測到 | 裝 |
|--------|-----|
| `go.mod` | `lang-go.md` |
| `package.json` | `lang-node.md` |
| `pyproject.toml` / `requirements.txt` | `lang-python.md` |
| `.tsx` / `vite.config.*` / React | `lang-frontend.md` |
| 都沒有 | 全裝 |

## Kiro CLI 的差別

Kiro CLI 跟 Claude Code 的設計模型不完全重疊，對應表：

| Claude Code | Kiro CLI | 狀態 |
|------------|---------|------|
| Rules（`paths:`） | Steering（`inclusion: fileMatch` + `fileMatchPattern`） | ✅ 自動轉換 |
| Skills | Steering `inclusion: manual` | ✅ 裝在 `on-demand/` |
| Agents（markdown） | Agents（**JSON**） | ✅ 自動轉換格式 |
| Commands（`/commit`） | — | ❌ Kiro CLI 無對應功能 |
| Hooks | Hooks（event 名不同） | ❌ 模型差太多，不硬裝 |
| `settings.json`（專案） | 機器層級設定 | ❌ 不是專案共享 |

## 標準內容

### Core Rules — 永遠載入

| 檔案 | 內容 |
|------|------|
| [ai-behavior.md](ai-behavior.md) | 5 步驟 flow、commit 頻率、completion report |
| [code-quality.md](code-quality.md) | TDD、錯誤處理、typing、API endpoint 流程 |
| [architecture.md](architecture.md) | 分層架構、DI、模組邊界 |

### Language Rules — 偵測到才裝

| 檔案 | 語言 | 涵蓋 |
|------|------|------|
| [lang-node.md](lang-node.md) | Node / TypeScript | pnpm、ESLint、Prettier、Zod、vitest |
| [lang-python.md](lang-python.md) | Python | uv、ruff、FastAPI、Pydantic、pytest |
| [lang-go.md](lang-go.md) | Go | go mod、golangci-lint、table-driven tests |
| [lang-frontend.md](lang-frontend.md) | Frontend | React、元件設計、a11y |

### Skills — Claude 按需呼叫

| Skill | 來源 | 觸發場景 |
|-------|------|---------|
| `security-check` | [security.md](security.md) | 新增 API、上線前、處理使用者輸入 |
| `infra-ops` | [project-ops.md](project-ops.md) | Docker、CI/CD、git workflow |
| `harness-review` | [harness-engineering.md](harness-engineering.md) | 系統性改進 |
| `browser-verify` | [agent-browser-skill.md](agent-browser-skill.md) | 前端視覺驗證 |

### Agent + Commands — 支撐 Verify / Commit

| 檔案 | 用途 |
|------|------|
| [agents/code-reviewer.md](agents/code-reviewer.md) | Subagent：結構化審查變更（Must Fix / Should Consider / OK） |
| [commands/commit.md](commands/commit.md) | `/commit`：lint + test + 規範化 commit message |
| [commands/review.md](commands/review.md) | `/review`：呼叫 code-reviewer subagent |

### Hooks + Settings

| 檔案 | 觸發 | 做什麼 |
|------|------|-------|
| [hooks/auto-format.sh](hooks/auto-format.sh) | `PostToolUse` Edit/Write | 依副檔名跑 gofmt / ruff / prettier（失敗不擋） |
| [hooks/secret-guard.sh](hooks/secret-guard.sh) | `PreToolUse` Bash | 擋 `.env`、`rm -rf`、`curl \| sh`、SSH key |
| [settings.json](settings.json) | — | 團隊預設權限 + hooks 掛載（裝成 `.claude/settings.json`） |

## 更新

```bash
./.aicoding-update.sh
```

## 知識庫 (`docs/`)

解釋背後設計原則的文章，**不**裝進專案：

| 文章 | 主題 |
|------|------|
| [逐步揭露.md](docs/逐步揭露.md) | 為什麼不該一次塞爆 context |
| [context管理.md](docs/context管理.md) | Skills、memory、subagents、compaction |
| [agent-harness-基本原則.md](docs/agent-harness-基本原則.md) | Agent 系統 3 原則 |
| [我可以停掉什麼.md](docs/我可以停掉什麼.md) | 定期檢視什麼還需要 |
| [使用指南.md](docs/使用指南.md) | 團隊使用指南（onboarding、daily workflow、狀況排解） |
| [github調查報告-dotclaude結構.md](docs/github調查報告-dotclaude結構.md) | GitHub 上 `.claude/` 結構的實況調查 |

## 貢獻：語言政策

- **給 AI 看的檔案**（rules、skills、agents、commands、hooks、`CLAUDE.md`）一律用**英文**。
- **給人看的文件**（`docs/`、本 README）可以中英並存。
- **改動 README 時，`README.md` 跟 [`README.zh-TW.md`](README.zh-TW.md) 必須同步更新**。

## License

MIT
