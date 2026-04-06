# Progressive Disclosure

不要一次把所有資訊全部塞給 AI。讓 AI 自己決定什麼時候需要什麼資訊。

## 核心概念

把資訊分層：
- **最前面**：很短的大綱，只有 20-30 行
- **需要的時候**：才翻詳細內容

## Skills 的例子

```yaml
# SKILL.md frontmatter — 只有幾行描述
name: cloudflare
description: Cloudflare Tunnel/R2/Pages 操作。觸發於：DNS 設定、Tunnel 管理、R2 上傳
```

```markdown
# 完整的 Cloudflare skill 內容（很長）
# 需要的時候再讀
```

## 為什麼有效

- **成本**：每次 API 請求都有 cost，context 越長越貴
- **注意力**：Claude 的注意力有限，太多資訊反而稀釋重點
- **適用性**：不是每個 task 都需要所有資訊

## 常見錯誤

❌ 把所有 rules 全部 auto-load  
✅ 只放 pointer，需要時再翻

❌ system prompt 寫幾百行 instruction  
✅ 每個 instruction 都問「這 rarely used 嗎？」

## 什麼適合放最前面

- 觸發條件（什麼情況用這個）
- 最高價值的 gotchas（最常見的坑）
- 檔案結構的大綱

## 什麼適合之後再揭露

- 詳細的 API 文件
- 完整的 error handling 流程
- 很少用到的 edge case
