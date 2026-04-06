# Agent Harness 基本原則

搭 agent 系統的三大原則。

**來源**: [Anthropic Blog - Harnessing Claude's Intelligence](https://claude.com/blog/harnessing-claudes-intelligence)

---

## 原則 1：用 Claude 擅長的工具

Claude 最強的是：
- **Bash** — 幾乎所有操作都可以用
- **Text editor** — viewing, creating, editing files

SWE-bench 49%（當時最高）就靠這兩個工具。

Skills、programmatic tool calling、memory — 都是這兩個工具的組合應用。

**不要重新發明輪子**。

---

## 原則 2：問「可以停掉什麼？」

不要把 tool 結果全部傳回給 Claude。讓它自己決定什麼重要。

例如：讀一個大表格，只在意某一欄。
- ❌ 整個表格塞給 Claude
- ✅ 讓 Claude 自己寫 code 處理資料，只把結果傳回來

**把 orchestration 決定權還給 model**。

---

## 原則 3：讓 Claude 自己管理 context

| 機制 | 作用 |
|------|------|
| **Skills** | 需要的時候再讀，不需要全部預先載入 |
| **Memory folder** | Claude 自己寫檔案，下次需要的時候讀 |
| **Subagents** | fork 新鮮的 context window 做隔離的工作 |
| **Compaction** | 總結過去的 context，保持長任務的連續性 |

### 實證

- Sonnet 3.5：把 memory 當 transcript 寫（錯誤用法）
- Opus 4.5+：寫 tactical notes，有組織的目錄結構
- Opus 4.6 + subagents：BrowseComp 準確率 +2.8%
- Opus 4.6 + compaction：BrowseComp 84%（Sonnet 4.5 停在 43%）

---

## 核心問題

> **「我可以停掉什麼？」**

定期問這個問題。Model 變強，過去的假設會過時。
