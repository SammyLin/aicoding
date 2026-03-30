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

- Write tests BEFORE implementation (TDD). When asked to implement a feature, generate the test first, then the implementation.
- After writing or modifying code, run the project's test command. If the test fails, fix the code until tests pass.
- After tests pass, run lint. Fix any issues before considering the task complete.
- Minimum coverage: aim for >70% on production code. For MVP, >30% is acceptable.
- Use the test command documented in the project config. Do not guess.

Verification sequence (run after every implementation):
1. Run tests → make test / pytest / go test ./...
2. Run linter → make lint / ruff check / golangci-lint run
3. All must pass before reporting completion
