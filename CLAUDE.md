# aicoding repo

團隊起新系統時的 AI 編碼標準安裝器。使用 **progressive disclosure**：核心規則永遠載入、語言規則依 `paths:` 條件載入、情境規則作為 Skills 按需呼叫、加上 Agent + Commands + Hooks 支撐 5 步驟 flow。

## Repo 結構

```
核心規則（永遠安裝到 .claude/rules/）：
  ai-behavior.md         — 5 步驟 flow、commit 頻率
  code-quality.md        — TDD、錯誤處理、typing
  architecture.md        — 分層架構、DI

語言規則（自動偵測；有 paths: frontmatter，只在相關檔案時載入）：
  lang-node.md           — 若有 package.json
  lang-python.md         — 若有 pyproject.toml / requirements.txt
  lang-go.md             — 若有 go.mod
  lang-frontend.md       — 若有 .tsx / vite.config / React

情境規則（包成 Skills，agent 按需呼叫）：
  security.md            → .claude/skills/security-check/SKILL.md
  project-ops.md         → .claude/skills/infra-ops/SKILL.md
  harness-engineering.md → .claude/skills/harness-review/SKILL.md
  agent-browser-skill.md → .claude/skills/browser-verify/SKILL.md

Agent + Commands（支撐 Verify / Commit 流程）：
  agents/code-reviewer.md    → .claude/agents/code-reviewer.md
  commands/commit.md         → .claude/commands/commit.md
  commands/review.md         → .claude/commands/review.md

Hooks + Settings（自動化與權限）：
  hooks/auto-format.sh       → .claude/hooks/auto-format.sh
  hooks/secret-guard.sh      → .claude/hooks/secret-guard.sh
  settings.example.json      → .claude/settings.json

其他：
  setup.sh                   — 安裝器（偵測語言、轉換 Kiro 格式）
  docs/                      — 知識庫（不安裝到專案）
```

## 5-Layer Design

| 層 | 位置 | 載入時機 | 內容 |
|---|------|---------|------|
| 1. Core | `.claude/rules/` | 永遠 | 每個任務都需要 |
| 2. Language | `.claude/rules/` | 檔案符合 `paths:` | 語言慣例 |
| 3. Skills | `.claude/skills/` | Claude 判斷需要 | Security / ops / harness / browser |
| 4. Agent + Commands | `.claude/agents/` + `.claude/commands/` | 使用者呼叫 | Verify / Commit 流程 |
| 5. Hooks + Settings | `.claude/hooks/` + `.claude/settings.json` | 事件觸發 | 自動 format、擋危險指令 |

## Kiro CLI 的對應

Kiro CLI 格式跟 Claude 不完全重疊，setup.sh 會自動做必要轉換：

| Claude | Kiro CLI | 做什麼 |
|--------|---------|-------|
| `paths:` YAML array | `inclusion: fileMatch` + `fileMatchPattern: "a\|b\|c"` | setup.sh 自動轉換 |
| Agent markdown | Agent JSON | setup.sh 解析 frontmatter + body，寫成 JSON |
| Commands / Hooks / settings.json | — | ❌ Kiro CLI 不支援，不安裝 |

## 編輯原則

- **核心規則**：保持精簡、價值密度高。這些是 ALWAYS 在 context
- **語言規則**：自成一格，靠 `paths:` 限定載入時機。偵測邏輯在 `setup.sh` `detect_languages()`
- **情境規則**：原始檔（security.md 等）由 setup.sh 包成 SKILL.md 加 frontmatter
- **Skills description**（~250 字元）是觸發詞 — 寫得越像使用者問的話越好
- **Agent + Commands**：**克制原則** — 只裝 1 agent + 2 commands，對應 5 步驟的 Verify + Commit。多裝是人設動物園
- **Hooks**：只裝與語言無關、低風險的兩個（auto-format、secret-guard）
- **settings.json**：team-level 權限共識，個人偏好不放這裡

## 新增一項的流程

### 新增 Skill

1. 寫原始檔 `foo.md`
2. 加到 `setup.sh` 的 `SKILL_NAMES` / `SKILL_SOURCES` / `SKILL_DESCRIPTIONS` 陣列

### 新增語言

1. 寫 `lang-xxx.md`，開頭加 `paths:` frontmatter
2. 加到 `setup.sh` 的 `LANG_FILES` / `LANG_DETECT` / `LANG_LABELS` / `LANG_DESCRIPTIONS` / `LANG_KIRO_PATTERN` 陣列

### 新增 Agent / Command / Hook

**先想想非裝不可嗎？** 小心 agent 人設動物園、指令湊數、每次 edit 跑全測試這類反模式。
如果真的要：

1. 寫在 `agents/` / `commands/` / `hooks/`
2. 加到 `setup.sh` 的 `AGENT_FILES` / `COMMAND_FILES` / `HOOK_FILES`

## 測試

```bash
# 啟動本地 HTTP server 服務此 repo
python3 -m http.server 8765 --bind 127.0.0.1 &

# 在臨時目錄模擬 Go 專案
mkdir -p /tmp/test && cd /tmp/test && touch go.mod
BASE_URL=http://127.0.0.1:8765 bash <(curl -s http://127.0.0.1:8765/setup.sh)

# 檢查結果
find /tmp/test -type f | sort
```

`setup.sh` 支援 `BASE_URL` 環境變數覆寫，方便本地測試。
