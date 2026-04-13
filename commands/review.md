---
description: 呼叫 code-reviewer subagent 審查目前所有未提交的變更
allowed-tools: Task, Bash(git status)
---

使用 Task 工具呼叫 `code-reviewer` subagent，讓它獨立審查當前所有變更。

步驟：

1. 先跑 `git status --short` 確認有變更可審
2. 如無變更，回報「無變更可審」並結束
3. 呼叫 `code-reviewer` subagent，prompt 為：
   > 審查目前 staged + unstaged 所有變更，依你的 checklist 給出結構化報告。
4. 直接把 subagent 的報告呈現給使用者，**不要**自己再加一層摘要或評論

這個指令的重點是提供「獨立 context 視角」的審查，所以不要污染。
