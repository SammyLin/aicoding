# Context 管理

讓 Claude 自己管理自己的 context，不要幫它做太多。

---

## 4 種機制

### 1. Skills = 逐步揭露

YAML frontmatter 是 short description，進入 context。Full content 在需要的時候再去讀。

### 2. Memory Folder

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

### 3. Subagents

Fork 新鮮的 context window 做隔離的工作。

- Opus 4.6 + subagents → BrowseComp +2.8%
- 適合：需要完全隔離、不受過往 context 影響的工作

### 4. Compaction

總結過去的 context，保持長任務的連續性。

- Sonnet 4.5：不論給多少 budget，準確率停在 43%
- Opus 4.5+：可以 scale 到 68%
- Opus 4.6：84%

---

## 不要做的事

❌ 幫 Claude 決定「這個要傳回來」  
✅ 讓它自己決定什麼結果要管

❌ 所有 instruction 預先載入  
✅ 需要的時候再揭露

❌ 過度保護，幫它避開所有風險  
✅ 讓它自己學會繞過坑
