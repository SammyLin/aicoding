# 寫好 Skills 的技巧

## 最高價值：Gotchas Section

Gotchas 是從失敗經驗中累積的。不是理論，是「這裡有坑」。

```
## Gotchas

- 用 `uv run` 不要直接 `python`，否則環境會錯
- `sqlite3` 在 Alpine image 沒有，要用 `apk add sqlite`
- PostgreSQL 在 Docker compose 裡的 hostname 等於 service 名稱
```

Gotchas 要隨著使用經驗更新。遇到一個坑，就加一條。

---

## 不要寫廢話

Claude 已經懂的東西不要寫。重點放在：
- 它不知道的
- 它容易搞錯的
- 它會繞遠路的

Example：
- ❌「Python 用 `def` 宣告函式」— Claude 知道
- ✅「這個專案用 `async def`，不要用普通 `def`」— Claude 需要知道

---

## 用資料夾結構

```
cloudflare-skill/
├── SKILL.md           # 觸發條件 + gotchas
├── references/
│   └── api.md         # API 詳細文件
├── scripts/
│   └── tunnel-check.sh
└── assets/
    └── tunnel-template.yml
```

---

## Description 是觸發條件

不是標題，是「什麼時候該用這個 skill」。

❌ `description: "Cloudflare skill"`  
✅ `description: "Cloudflare Tunnel、R2、Pages 操作。適用時機：新增 DNS record、管理 Tunnel、部署靜態網站到 R2"`

---

## 不要把 Claude 寫死

給它需要的資訊，但留彈性。Claude 會盡量遵守指令，太具體會讓它失去判斷力。

---

## Setup 流程

有些 skills 需要一開始的設定。

```json
// config.json
{
  "tunnel_id": "e322dbb8-...",
  "account_tag": "..."
}
```

如果沒有設定，問用戶。

---

## 一句話

> 最好的 skill：一行描述 + 幾個 gotchas，隨著遇到新坑慢慢長大。
