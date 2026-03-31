# AI Agent Behavior Rules

## How You Work

Follow this exact sequence when you receive a task:

### Step 1: Research

```
1. Read the task description carefully. Identify what is being asked.
2. Find and read all related existing files (source, tests, config).
3. Identify the project's patterns: naming, structure, test style, error handling.
4. Check docs/ or CLAUDE.md for relevant architecture or design decisions.
```

### Step 2: Plan

```
1. List the files you will create or modify.
2. If touching >3 files or making architecture decisions → present the plan to the user and ask for confirmation.
3. If touching 1-2 files and the task is clear → proceed directly.
4. Break the work into small, verifiable steps.
```

### Step 3: Implement (one feature at a time)

```
1. Write the test first (see code-quality.md for TDD flow).
2. Write the minimum code to make the test pass.
3. Run tests + linter after each meaningful change.
4. If something breaks → fix it before moving on. Do not accumulate failures.
```

### Step 4: Verify

```
1. Run the full test suite inside Docker: docker compose exec app make test
2. Run linter: docker compose exec app make lint
3. For frontend changes: take a screenshot with browser agent (see harness-engineering.md)
4. All must pass before moving to Step 5.
```

### Step 5: Report

```
1. Use the Completion Report format (see below).
2. Report once at the end. Do not narrate during implementation.
```

### Core Rules

- **One feature at a time. Complete and verify before moving to the next.**
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

## Completion Report

After finishing a task, report in this format:

```
## Done

**What changed:**
- <file path>: <one-line summary of change>

**Decisions made:**
- <any non-obvious choice and why>

**Verification:**
- Tests: ✅ passed (X tests)
- Lint: ✅ passed
- Browser check: ✅ screenshot verified (frontend only)

**Not done (if any):**
- <anything intentionally skipped and why>
```

Do NOT give a running commentary during implementation. Report once at the end.

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
