# Code Quality & Testing Standards

You MUST follow these rules when writing, reviewing, or modifying code.

## Principles

- Follow DRY, KISS, SOLID, YAGNI.
- Prefer composition over inheritance.
- Prefer explicit over implicit — no magic strings, barrel exports, or auto-discovery.
- Use Dependency Injection over global state.
- Thin controllers, fat services — business logic belongs in testable service layers.

## Style

- Apply the project's configured linter and formatter. Do not disable rules without explicit user approval.
- Follow the naming conventions documented in this project. If none exist, use: snake_case for Python files/functions, PascalCase for classes, camelCase for Go unexported.
- No commented-out code. No dead code. Delete it.

## Error Handling

- Use specific error types with actionable messages.
  - Go: fmt.Errorf("context: %w", err) — always wrap with context. Never panic for expected failures.
  - Python: domain-specific exception classes. Raise from services, catch and convert to HTTP at handler layer only.
- Never use catch-all exception handlers that silently swallow errors.
- Every error must carry: what operation failed, why it failed, and enough context to reproduce.

## Types & Interfaces

- Use strict typing everywhere. No untyped function signatures.
  - Go: all function parameters and returns must have explicit types.
  - Python: type hints on all function signatures. Use Protocol for structural typing.
- Define typed interfaces at module boundaries: Pydantic models for runtime validation, type hints for function signatures, OpenAPI specs for APIs.
- All API endpoints return a consistent shape or the project's documented convention.

## Testing

Write tests BEFORE implementation (TDD). Follow this exact sequence:

### Step 1: Write the test

```
1. Read the existing test files to understand the project's test patterns and conventions.
2. Write a failing test that describes the expected behavior.
3. Run the test — confirm it FAILS for the right reason (not a syntax error).
```

### Step 2: Implement the code

```
1. Write the minimum code to make the test pass.
2. Run the test — confirm it PASSES.
3. Refactor if needed, re-run to confirm still passing.
```

### Step 3: Verify everything

```
1. Run full test suite   → make test / pytest / go test ./... / npm test
2. Run linter            → make lint / ruff check / golangci-lint run / npm run lint
3. Run type checker      → mypy / tsc --noEmit (if applicable)
4. All must pass before reporting completion.
```

### Test Rules

- Minimum coverage: >70% on production code. For MVP, >30% is acceptable.
- Use the test command documented in the project config. Do not guess.
- Colocate tests next to source files. Use the project's naming convention (e.g., `_test.go`, `test_*.py`, `*.test.ts`).
- Mock external dependencies (DB, APIs, file system). Never make real network calls in unit tests.
- Each test must be independent and idempotent — no shared mutable state between tests.
- Name tests descriptively: `test_create_order_returns_error_when_inventory_empty`, not `test_order_1`.
