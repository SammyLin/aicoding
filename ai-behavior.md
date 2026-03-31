# AI Agent Behavior Rules

## How You Work

Follow this exact sequence when you receive a task:

### Step 1: Research

```
1. Read the task description carefully. Identify what is being asked.
2. Find and read all related existing files (source, tests, config).
3. Identify the project's patterns: naming, structure, test style, error handling.
4. Check docs/ or CLAUDE.md for relevant architecture or design decisions.
5. Check if the project has i18n requirements:
   - Look for existing i18n config, translation files, or locale setup.
   - If i18n is already set up → follow the existing pattern for all new user-facing strings.
   - If i18n is not set up but the project targets multilingual users → flag this to the user
     and suggest setting up i18n before hardcoding strings.
   - See language-specific standards for recommended i18n frameworks.
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

### Step 4: Verify (closed loop — do NOT skip any step)

```
1. Run tests inside Docker           → docker compose exec app make test
2. Run linter inside Docker           → docker compose exec app make lint
3. Check for type errors              → language-specific type checker (if configured)
4. Self-review your own code for:
   - Layer violations (handler importing repo directly?)
   - Unwrapped errors (missing context in error messages?)
   - Hardcoded values (should be in config / env?)
   - Missing tests for new logic
   - Security: input validated? secrets in code? (see security.md checklist)
5. For frontend: take screenshot       → browser agent, verify layout + interactions
6. For API: test with curl             → verify request/response shape matches spec
7. Read logs for warnings/errors       → docker compose logs app
8. ALL green → move to Step 5
   ANY red  → fix and re-run from step 1. Do not skip to reporting.
```

### Step 5: Strengthen the Harness (feedback loop)

After fixing any issue during Step 4, ask yourself:

```
1. "Could this mistake happen again?"
2. If yes → add a permanent guardrail in the SAME PR:
   - Forgot to wrap an error?      → Add lint rule
   - Handler imported repo?         → Add structural test
   - Missing input validation?      → Add middleware or CI check
   - Convention not followed?       → Update docs + add linter enforcement
   - Same bug could recur?          → Add regression test
3. If the rule belongs in the shared standards → suggest the update to the user.
```

The goal: every mistake makes the system stronger. The same mistake never happens twice.

### Step 6: Report

```
1. Use the Completion Report format below.
2. Include ALL verification results and any harness improvements made.
3. Report once at the end. Do not narrate during implementation.
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
- Type check: ✅ passed
- Self-review: ✅ no layer violations, errors wrapped, no hardcoded values
- Browser check: ✅ screenshot verified (frontend only)
- curl check: ✅ response shape correct (API only)

**Harness strengthened (if applicable):**
- <lint rule / structural test / CI check added to prevent recurrence>

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
