# Skills 分發管理

如何分享和管理 Skills。

---

## 小團隊（< 10 人）

把 skills 放進專案 repo：

```
project/
├── .claude/
│   └── skills/
│       ├── billing-lib/
│       ├── deploy-workflow/
│       └── ...
```

簡單，缺點是每個 repo 都要放一份。

---

## 成長團隊（> 10 人）

建立內部 plugin marketplace：

1. 上传到 sandbox folder（公開測試）
2. 在 Slack 或論壇分享
3. 有足夠人用之後，PR 到 marketplace

---

## Curation 很重要

很容易產生：
- 重複的 skills
- 品質不好的 skills
- 沒人用的 skills

所以 release 前要有審核機制。

---

## 測量 Skills 效果

用 `PreToolUse` hook 記錄使用情況：
- 哪些 skills 受歡迎？
- 哪些 skills 該被觸發但沒有？

找到 gap，就能知道該加什麼。

---

## 範例：On-Demand Hooks

Skills 可以包 on-demand hooks，只在 skill 被呼叫時啟動，session 結束就消失。

```
/careful — 阻擋危險指令（rm -rf, DROP TABLE, kubectl delete）
/freeze — 只允許編輯特定目錄
```

這些不是 always-on，所以不會瘋狂干擾。
