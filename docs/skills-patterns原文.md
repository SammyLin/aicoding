# Skills Patterns 原文重點

**來源**: [Anthropic Blog - Skills Patterns](https://claude.com/blog/skills-patterns)

---

## Skills 是什麼

Skills 是 Anthropic Claude Code 最常用的擴充點之一。靈活、好做、容易分享。

最大的誤解：Skills 不是「只是 markdown 檔案」。最有趣的部分是：Skills 是**整個資料夾**，裡面可以放腳本、素材、資料等。

---

## 9 種 Skills 類型

### 1. Library & API Reference
說明怎麼用 library、CLI、SDK。可以是內部或外部的。
- 通常會放 reference code snippets 和 gotchas list
- 例子：`billing-lib`、`internal-platform-cli`、`frontend-design`

### 2. Product Verification
說明怎麼測試或驗證程式碼是否正確。通常會搭配外部工具（playwright、tmux 等）使用。
- 非常有用，可以省很多人工 QA 時間
- 建議：讓 Claude 錄製操作影片，工程师可以看
- 例子：`signup-flow-driver`、`checkout-verifier`、`tmux-cli-driver`

### 3. Data Fetching & Analysis
連接到資料和監控系統。
- 包括 credential、dashboard ids、常見 workflow
- 例子：`funnel-query`、`cohort-compare`、`grafana`

### 4. Business Process & Team Automation
把重複的工作自動化成一鍵指令。
- 通常包含其他 skills 或 MCPs 的相依性
- 建議：把之前的結果存在 log file，保持一致性
- 例子：`standup-post`、`create-\<ticket-system\>-ticket`、`weekly-recap`

### 5. Code Scaffolding & Templates
生成框架樣板。
- 適合有自然語言需求的 scaffolding（沒辦法純 code 表達的）
- 例子：`new-\<framework\>-workflow`、`new-migration`、`create-app`

### 6. Code Quality & Review
執行 code quality 把關和 review。
- 可以用 deterministic scripts 確保最大穩健性
- 建議：當成 GitHub Actions 或 hooks 的一環
- 例子：`adversarial-review`、`code-style`、`testing-practices`

### 7. CI/CD & Deployment
幫忙 fetch、push、部署程式碼。
- 可能會呼叫其他 skills 收集資料
- 例子：`babysit-pr`、`deploy-\<service\>`、`cherry-pick-prod`

### 8. Runbooks
接收症狀（Slack thread、alert、error signature），走過 multi-tool 調查，生產結構化報告。
- 例子：`\<service\>-debugging`、`oncall-runner`、`log-correlator`

### 9. Infrastructure Operations
執行日常維運和操作程序。有些包含破壞性操作，需要 guardrails。
- 讓工程師更容易遵守 best practices
- 例子：`\<resource\>-orphans`、`dependency-management`、`cost-investigation`

---

## 寫 Skills 的技巧

### 1. 不要寫廢話
Claude Code 已經很懂你的 codebase 和 coding。不要把重點放在它已經懂的東西上。

例子：`frontend-design` skill 是由 Anthropic 工程師和 customer 來回迭代做出來的，慢慢改善 Claude 的設計品味，避開 Inter font 和紫色漸層這種經典爛品味。

### 2. Gotchas 最重要
任何 skill 裡最高價值的內容就是 **Gotchas** section。從 common failure points 慢慢累積。理想上，隨著使用經驗更新。

### 3. 用檔案系統和逐步揭露
整個檔案系統都是 context engineering 的一種。告訴 Claude skill 裡有哪些檔案，它會在適當的時機去讀。

最簡單的形式：在其他 markdown 檔案放 pointer，讓 Claude 在需要的時候去讀（例如：把詳細的 function signatures 和使用範例放到 `references/api.md`）。

另一個例子：如果最終輸出是 markdown，可以放 `assets/template.md` 讓 Claude copy 使用。

### 4. 不要把 Claude 寫死
Claude 會盡量遵守指令，因為 Skills 太容易重複使用，所以要小心不要寫得太具體。給它需要的資訊，但留彈性讓它適應情況。

### 5. Think Through Setup
有些 skill 需要先從用戶取得設定。例如：如果你做一個 standup-post skill，可能要問「post 到哪個 Slack 頻道？」

好方法：用 `config.json` 存這些設定。如果沒設定，agent 可以問用戶。

如果想讓 agent 呈現結構化、多選項問題，可以用 `AskUserQuestion` tool。

### 6. Description 是給 Model 看的
當 Claude Code 啟動 session，它會建立所有可用 skills 的列表和 description。這個列表就是 Claude 拿來決定「這個 request 該用哪個 skill」的根據。

所以 description 不是摘要，是「什麼時候觸發這個 PR」的描述。

### 7. Memory 和存資料
有些 skill 可以用記憶體形式存資料。可以用 append-only log file、JSON、或 SQLite。

例如：`standup-post` skill 可能在 `standups.log` 存每次 post 的內容，下次跑的時候 Claude 可以讀自己的歷史，知道昨天到今天發生了什麼變化。

注意：存在 skill 目錄裡的資料，升級 skill 時可能會被刪掉。用 `\$\{CLAUDE_PLUGIN_DATA\}` 可以穩定存放。

### 8. Store Scripts & Generate Code
給 Claude scripts 和 libraries，讓它把時間花在 composition（決定下一步做什麼）而不是重構 boilerplate。

例如：data science skill 裡可以有一個從 event source 拿資料的 function library。當需要複雜分析時，Claude 可以即時生程式來組合這些功能。

---

## On-Demand Hooks

Skills 可以包 hooks，只在 skill 被呼叫時啟動， lasting for the session duration。適合不想 always-on 但有時候非常有用 guardrails。

例子：
- `/careful` — 阻擋 `rm -rf`、`DROP TABLE`、`force-push`、`kubectl delete`
- `/freeze` — 只允許 Edit/Write 在特定目錄。debugging 時很有用。

---

## 分發 Skills

### 小團隊
檢查 skills 到 repo 即可（under `.claude/skills`）。缺點：每個 skill 都增加一點 context。

### 成長團隊
建立內部 plugin marketplace。需要 curation（審核）機制，不然很容易產生壞掉或重複的 skills。

建議：
- 上传到 sandbox folder 公開測試
- 在 Slack 或論壇分享
- 有足夠人用之後，PR 到 marketplace

---

## 測量 Skills

用 `PreToolUse` hook 記錄 skill 使用情況。可以發現：
- 哪些 skills 很受歡迎
- 哪些 skills 該被觸發但沒有

找到 gap，就知道該加什麼。

---

## 一句話

> Skills 最好一開始只有幾行和一個 gotcha，然後隨著 Claude 遇到新的 edge cases，慢慢長大。
