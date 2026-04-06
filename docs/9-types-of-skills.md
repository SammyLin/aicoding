# 9 Types of Skills

| # | 類型 | 用途 | 例子 |
|---|------|------|------|
| 1 | **Library & API Reference** | 怎麼用內部 library 或 SDK | billing-lib（計費 library 的坑） |
| 2 | **Product Verification** | 測試和確認功能正確 | signup-flow-driver（自動跑 Sign up → email驗證 → onboarding） |
| 3 | **Data Fetching & Analysis** | 連接資料和監控系統 | funnel-query（查用戶從註冊到付費的漏斗） |
| 4 | **Business Process** | 把重複工作自動化成一鍵 | standup-post（一鍵發 Standup 到 Slack） |
| 5 | **Code Scaffolding** | 生成框架樣板 | new-migration（資料庫遷移樣板） |
| 6 | **Code Quality & Review** | 程式碼 review 和品質把關 | adversarial-review（clone 一個新 agent 來 critique） |
| 7 | **CI/CD & Deployment** | 部署和發布 | babysit-pr（監控 PR → 重試失敗的 CI → 自動合併） |
| 8 | **Runbooks** | 故障排除手冊 | \<service\>-debugging（抓錯誤症狀 → 查工具 → 回報） |
| 9 | **Infrastructure Ops** | 日常維運操作 | \<resource\>-orphans（找孤兒 pods → 清理） |

---

## 最好的 Skills

- 清楚屬於一個類型
- 有 Gotchas section（最高價值）
- 有 setup 流程（config.json）
- Description 清楚說明觸發時機

---

## 混淆的 Skills

- 跨越多個類型
- 沒有 gotchas
- Description 寫得像標題而不是觸發條件
