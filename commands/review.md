---
description: Invoke the code-reviewer subagent to audit all uncommitted changes
allowed-tools: Task, Bash(git status)
---

Use the Task tool to spawn the `code-reviewer` subagent to independently review the current diff.

Steps:

1. Run `git status --short` to confirm there are changes to review.
2. If there are none, report "no changes to review" and stop.
3. Invoke the `code-reviewer` subagent with prompt:
   > Review all staged + unstaged changes against your checklist and produce a structured report.
4. Present the subagent's report verbatim. **Do not** add your own summary or commentary on top.

The point of this command is to deliver an *independent-context* review — don't pollute it.
