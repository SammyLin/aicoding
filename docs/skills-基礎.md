# Skills 基礎

Skills 是什麼？

---

## 不是 just markdown，是整個資料夾

一個 skill 可以包含：
- `SKILL.md` — 描述和觸發條件
- `scripts/` — 可以直接跑的腳本
- `assets/` — 素材、樣板
- `references/` — API 詳細文件
- `config.json` — 設定值

Claude 可以 explore 整個資料夾，找出需要的東西。

---

## 觸發條件是 description

Description 不是標題，是「什麼情況下該用這個 skill」。

```yaml
name: checkout-verifier
description: 驅動 checkout UI 跑 Stripe test card，驗證 invoice 是否正確寫入。適用時機：測試付款流程
```

Claude 啟動時，會 scan 所有 skill descriptions，決定「這個需求該用哪個 skill」。

---

## 逐步揭露

1. 最前面：YAML frontmatter（幾行）
2. 需要時：讀 SKILL.md 完整內容
3. 需要時：跑 scripts/ 或讀 references/

不要一次全部揭露。
