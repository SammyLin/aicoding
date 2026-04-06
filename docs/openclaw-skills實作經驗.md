# OpenClaw Skills 實作經驗

---

## 小六常用的 Skills（按頻率）

### 高頻
| Skill | 用途 |
|-------|------|
| `github` | 看 PR status、CI 結果，建立 issue |
| `weather` | 查天氣 |
| `coding-agent` | 叫 Claude Code 寫複雜程式 |
| `cloudflare` | DNS、Tunnel、R2 操作 |

### 中頻
| Skill | 用途 |
|-------|------|
| `gh-issues` | GitHub issues + PR 流程 |
| `blogwatcher` | 監控 RSS feed 更新 |
| `things-mac` | 管理 Things 3 task |

### 低頻
| Skill | 用途 |
|-------|------|
| `apple-notes` | 管理 Apple Notes |
| `gifgrep` | 找 GIF |
| `openai-image-gen` | 生成圖片 |

---

## 現有問題

1. **Description 不夠清楚** — 有些 skill description 只有一行，觸發條件不明確
2. **Gotchas 沒有累積** — 使用失敗的經驗沒有記錄
3. **有些 skill 根本沒在用** — 可能是觸發條件不明，或功能重疊

---

## 可以改善的方向

1. **Description 改成觸發條件格式**
   ```
   觸發時機：當你需要查 GitHub PR status、review code、或建立 issue 時
   ```

2. **建立 gotchas.md**
   - 每次踩坑就加一筆
   - 例如：cloudflare tunnel 的 timeout 問題

3. **Skills 定期 review**
   - 每季看一次：哪些從來沒用到？該刪嗎？
   - 問「這個 skill 可以停掉嗎？」

---

## Reference

- 小六的 skills 目錄：`~/.openclaw/skills/`
- 小六的 workspace：`~/.openclaw/workspace-roku/`
- 小六的 memory：`~/.openclaw/workspace-roku/memory/`
