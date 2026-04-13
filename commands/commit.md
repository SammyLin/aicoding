---
description: 跑完整 lint + test，然後產生符合規範的 commit message
argument-hint: [optional 補充說明]
allowed-tools: Bash(git:*), Bash(npm:*), Bash(pnpm:*), Bash(go:*), Bash(pytest:*), Bash(uv:*), Bash(ruff:*), Read
---

執行以下流程，每步失敗就停下回報，**不要繼續**：

## 1. 檢查是否有變更

```bash
git status --short
```

如果沒有 staged 或 unstaged 變更，告訴使用者「無變更可提交」並結束。

## 2. 偵測專案類型，跑 lint + test

依偵測到的檔案選對應指令：

| 偵測到 | Lint | Test |
|--------|------|------|
| `package.json` with `pnpm-lock.yaml` | `pnpm run lint` | `pnpm test` |
| `package.json` with `package-lock.json` | `npm run lint` | `npm test` |
| `go.mod` | `go vet ./...` | `go test ./...` |
| `pyproject.toml` | `uv run ruff check .` | `uv run pytest` |

若指令不存在（例如 `pnpm run lint` script 沒定義）就跳過那一步，不要失敗。

## 3. 總結變更意圖

跑 `git diff --cached` 和 `git diff`，閱讀後回答兩個問題：

1. **為什麼要做這個變更？**（動機、要解決的問題）
2. **主要改了哪些檔案或模組？**（scope）

不要描述逐行改了什麼字，那是 diff 本身的工作。

## 4. 草擬 commit message

格式：

```
<type>: <短述，繁體中文或英文皆可，≤ 60 字>

<選填：一段說明動機，為什麼這樣改。換行包在 72 字內。>
```

type 從這些挑：
- `feat` — 新功能
- `fix` — bug 修復
- `refactor` — 不改行為的重寫
- `docs` — 文件
- `test` — 只改測試
- `chore` — 雜項（依賴、設定檔、CI）

範例：
```
feat: 加 code-reviewer agent 與 /commit /review 指令

對應 5 步驟 flow 中的 Verify 與 Commit，把常見 best practice
固化成團隊預設。
```

## 5. 確認後提交

**先把草擬的 message 顯示給使用者，等確認**。然後：

```bash
git add -A
git commit -m "<drafted message>"
```

最後跑 `git log --oneline -1` 確認提交成功。

## 使用者補充

$ARGUMENTS
