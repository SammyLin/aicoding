# Dedicated Tools vs General Bash

## 比較

| | **Bash tool** | **Dedicated tool** |
|---|---|---|
| 能力 | 廣泛，什麼都能做 | 有限，但有結構 |
| Harness 能看到什麼 | 只有 command string | Typed arguments，structured |
| 控制力 | 低 | 高（可以攔截、審計、render） |
| 適合場景 | 一般腳本、操作 | 高風險動作、需要審計的動作 |

---

## 什麼時候用 Dedicated tool

1. **Security boundary** — 外部 API call、刪除資料、付費操作
2. **不可逆的動作** — `DROP TABLE`、`rm -rf`、`force-push`
3. **需要 User confirmation** — 要問用戶才能繼續的動作
4. **需要 Observability** — structured logging、審計追蹤
5. **需要 Render UI** — 顯示成 modal、多選項等

## 什麼時候用 Bash

- 一般腳本
- 組裝其他工具
- 不需要特殊控制的操作

---

## 決策框架

> 「這個該 promote 成 dedicated tool 嗎？」

定期 re-evaluate。

Example：Claude Code 的 auto-mode 用另一個 Claude 審核 command，是另一種 security boundary 模式。

---

## 實務

```javascript
// Bash tool：harness 只得到 string，無法控制
{ tool: "bash", command: "kubectl delete pod xxx" }

// Dedicated tool：harness 可以審核、攔截
{ tool: "kubectl_delete", pod_name: "xxx" } 
// → PreToolUse hook 可以先問 user：「確定要砍這個 pod？」
```
