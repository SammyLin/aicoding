# AI Agent Behavior Rules

## How You Work

- Research before coding. Read relevant existing files first.
- Plan before executing. For features touching >3 files, create a plan first.
- **One feature at a time. Complete and verify before moving to the next.**
- Small, verifiable steps. Run verification after each meaningful change.
- Follow existing patterns. Do not introduce your preferred patterns over the project's.
- **No overengineering. Implement what was asked. No speculative abstractions.**

## When to Ask vs. When to Do

**Ask first when:**
- Task scope is unclear or has multiple possible approaches
- Affects >3 files or requires architecture decisions
- Involves external APIs, secrets, or security-sensitive code
- You're unsure about the expected output format or acceptance criteria

**Just do it when:**
- Task is well-defined and straightforward
- Only 1-2 files need changes
- You're confident about the implementation approach
- After completion, report what you did (not during the process)

## Decision Logging

When you make architectural or design choices:
- Document the "why" in commit messages or PR comments
- If choosing between multiple approaches, briefly note the tradeoffs
- This helps future maintainers understand your reasoning

## What You Must Not Do

- Do NOT modify files outside the current task scope without asking.
- Do NOT refactor unrelated code while implementing a feature.
- Do NOT delete tests or reduce coverage to make implementation pass.
- Do NOT disable linter rules or strict checks to avoid fixing errors.
- Do NOT add suppression comments without explicit user approval.

## Don't / Do Quick Reference

| Don't | Do Instead |
|-------|-----------|
| Business logic in handler | Logic in service layer |
| Import concrete types as deps | Inject interfaces/protocols |
| os.Getenv() in service code | Typed config struct via DI |
| if env == "prod" in logic | Feature flag in config |
| Giant utils/ package | Small focused shared modules |
| Speculative abstraction | Add when second use case appears |
| Raw panic / bare raise Exception | Wrapped error with context |
| print / fmt.Println for errors | Structured logger |
| Mixed old + new patterns | Only the new pattern |
| Catch-all exception handler | Specific catch with re-throw |
| Hardcoded config values | Environment variables |
| Monolithic 500-line file | Split by responsibility |
| Layer-based directory | Feature-based directory |

## Document Maintenance

When you notice these standards conflict with actual project patterns:
- Flag the discrepancy to the user.
- Suggest a specific update.
- Do not silently ignore a rule.
