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
- Follow the naming conventions in the language-specific rules (lang-node.md / lang-python.md / lang-go.md).
- No commented-out code. No dead code. Delete it.

## How to Implement an API Endpoint

Refer to the language-specific file for exact file names and commands. The general flow:

```
1. Define the request/response types     → domain types / schemas
2. Write the service test                → test for business logic
3. Implement the service method          → business logic layer
4. Run the test — confirm it passes
5. Write the handler (thin wrapper)      → HTTP layer (parse → service → respond)
6. Register the route                    → composition root
7. Update OpenAPI spec if applicable
8. Run full test suite + linter
9. Test manually via curl or browser agent
```

## Error Handling

- Use specific error types with actionable messages.
- Throw/raise from service layer. Catch and convert to HTTP status at handler layer only.
- Never use catch-all exception handlers that silently swallow errors.
- Every error must carry: what operation failed, why it failed, and enough context to reproduce.
- See lang-node.md / lang-python.md / lang-go.md for language-specific error patterns.

## Types & Interfaces

- Use strict typing everywhere. No untyped function signatures.
- Define typed interfaces at module boundaries.
- All API endpoints return a consistent shape or the project's documented convention.
- See the language file for validation libraries (Zod, Pydantic, etc.) and DI patterns.

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
1. Run full test suite   → make test (inside Docker)
2. Run linter            → make lint (inside Docker)
3. Run type checker      → if applicable
4. All must pass before reporting completion.
```

### Test Rules

- Minimum coverage: >70% on production code. For MVP, >30% is acceptable.
- Use the test command documented in the project config. Do not guess.
- Colocate tests next to source files.
- Mock external dependencies (DB, APIs, file system). Never make real network calls in unit tests.
- Each test must be independent and idempotent — no shared mutable state between tests.
- Name tests descriptively. See the language file for naming conventions.
