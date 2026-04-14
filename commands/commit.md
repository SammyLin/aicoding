---
description: Run the full lint + test suite, then produce a conventional commit message
argument-hint: [optional context]
allowed-tools: Bash(git:*), Bash(npm:*), Bash(pnpm:*), Bash(go:*), Bash(pytest:*), Bash(uv:*), Bash(ruff:*), Read
---

Run the following pipeline. If any step fails, stop and report. **Do not continue.**

## 1. Check for changes

```bash
git status --short
```

If there are no staged or unstaged changes, tell the user "no changes to commit" and stop.

## 2. Detect project type, run lint + test

Pick the command based on detected files:

| Detected | Lint | Test |
|----------|------|------|
| `package.json` with `pnpm-lock.yaml` | `pnpm run lint` | `pnpm test` |
| `package.json` with `package-lock.json` | `npm run lint` | `npm test` |
| `go.mod` | `go vet ./...` | `go test ./...` |
| `pyproject.toml` | `uv run ruff check .` | `uv run pytest` |

If a command isn't defined (e.g. no `lint` script in `package.json`), skip that step rather than fail.

## 3. Summarize the intent of the change

Run `git diff --cached` and `git diff`, then answer two questions:

1. **Why is this change being made?** (motivation, the problem it solves)
2. **Which files or modules are primarily affected?** (scope)

Do not describe line-by-line edits — that's what the diff is for.

## 4. Draft the commit message

Format:

```
<type>: <short summary, ≤ 60 chars>

<optional body: one paragraph on motivation — why this change.
Wrap lines at 72 chars.>
```

Pick `type` from:
- `feat` — new functionality
- `fix` — bug fix
- `refactor` — behavior-preserving rewrite
- `docs` — documentation only
- `test` — test-only change
- `chore` — housekeeping (deps, config, CI)

Example:

```
feat: add code-reviewer agent and /commit /review commands

Covers the Verify and Commit steps of the 5-step flow,
codifying common best practices as team defaults.
```

## 5. Commit after confirmation

**Show the drafted message to the user and wait for confirmation** before committing:

```bash
git add -A
git commit -m "<drafted message>"
```

Finally, run `git log --oneline -1` to confirm the commit succeeded.

## User-supplied context

$ARGUMENTS
