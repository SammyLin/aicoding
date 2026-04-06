# Harnessing Claude's Intelligence 原文重點

**來源**: [Anthropic Blog - Harnessing Claude's Intelligence](https://claude.com/blog/harnessing-claudes-intelligence)

---

## 核心三原則

### 1. 用 Claude 擅長的工具

Claude 最強的是 **bash** 和 **text editor**（viewing, creating, editing files）。

SWE-bench 49% 就是靠這兩個工具。Skills、programmatic tool calling、memory — 都是這兩個工具的組合應用。

**不要重新發明輪子**。

### 2. 問「可以停掉什麼？」

Agent harnesses 會假設「Claude 不能自己做到某件事」。隨著 Claude 變強，這些假設會過時，要定期重新測試。

**讓 Claude 自己串 workflow**：給它 code execution tool，讓它自己決定什麼 tool results 要管、什麼可以跳過。不要把所有結果都塞進 context。

**Example**：讀一個大表格，但只在意某一欄。
- ❌ 整個表格塞給 Claude
- ✅ 讓 Claude 自己寫 code 處理，只把結果傳回來

### 3. 小心設定 Boundaries

- Cache 優化
- Dedicated tools vs general bash
- 不要過度保護

---

## Cache Optimization

API 會把 context 寫到 breakpoint 為止的內容 cache。Cached tokens 成本 = 10% of base input tokens。

### 設計原則

| 原則 | 說明 |
|------|------|
| **Static first, dynamic last** | stable content（system prompt, tools）放前面，動態內容放後面 |
| **Messages for updates** | 要更新時，在尾端加 `<system-reminder>`，不要編輯已 cache 的 prompt |
| **Don't change models** | 不要在 session 中切換 model，cache 是 model-specific |
| **Carefully manage tools** | Tools 在 cache prefix 裡，加/減 tool 會 invalidates cache |
| **Move breakpoints** | 保持 cache 最新，把 breakpoint 移到最新 message |

---

## 讓 Claude 管理自己的 Context

### Skills = 逐步揭露

YAML frontmatter 是 short description，進入 context。Full content 在需要的時候再去讀。

不要把所有 instruction 都塞進 system prompt。每一個很少用的 instruction 都在消耗 Claude 的 attention budget。

### Memory Folder

讓 Claude 自己寫檔案，下次需要的時候讀。

- Sonnet 3.5：當 transcript 寫（錯誤 — 流水帳，檔案越來越多）
- Opus 4.5+：寫 tactical notes，有組織的目錄結構

```
/learnings.md
  - Bellsprout Sleep+Wrap combo: KO FAST with BITE
  - Gen 1 Bag Limit: 20 items max
/gameplay/
  - 3 gym badges
```

### Subagents

Fork 新鮮的 context window 做隔離的工作。

- Opus 4.6 + subagents → BrowseComp +2.8%
- 適合：需要完全隔離、不受過往 context 影響的工作

### Compaction

總結過去的 context，保持長任務的連續性。

- Sonnet 4.5：不論給多少 budget，準確率停在 43%
- Opus 4.5+：可以 scale 到 68%
- Opus 4.6：84%

---

## Dedicated Tools vs General Bash

### Bash tool
- 提供廣泛能力
- Harness 只得到 command string — 形狀都一樣，沒辦法控制

### Dedicated tool
- Typed arguments，harness 可以攔截、審計、render
- 適合：高風險動作、需要審計的動作

### 什麼該 promote 成 dedicated tool？

- **Security boundary**：外部 API call、刪除資料、付費操作
- **不可逆動作**：`DROP TABLE`、`rm -rf`、`force-push`
- **需要 User confirmation**：要問用戶才能繼續
- **需要 Observability**：structured logging、審計追蹤
- **需要 Render UI**：顯示成 modal、多選項

### Decision Framework

定期 re-evaluate：「這個該 promote 成 dedicated tool 嗎？」

Example：Claude Code 的 auto-mode 用另一個 Claude 審核 command，是另一種 security boundary 模式。

---

## 最重要的一句話

> **「我可以停掉什麼？」** — 這是要定期問的問題。

不要因為害怕，就加一堆 safety。Model 會越來越強，這些可能變成拖慢速度的垃圾。定期檢查，該刪就刪。

---

## 真實案例

**Sonnet 4.5 → Opus 4.5**

問題：Sonnet 4.5 在 context 快滿的時候會焦慮，開發者加了「提前結束」的機制。

後來升級到 Opus 4.5，問題自動消失了。那些「提前結束」的機制，變成多餘的 code，反而拖慢效能。

**結論**：Model 會變強，過去打的补丁可能沒用了，要定期刪掉。
