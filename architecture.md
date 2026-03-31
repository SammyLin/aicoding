# Architecture & Design Standards

These are guiding principles. Follow them by default. If a specific situation warrants deviation, explain your reasoning to the user before proceeding.

## Layered Architecture

Every backend service follows a clear layer separation. Each layer has a single responsibility and only depends downward.

```
Handler / Router          ← HTTP concern only: parse request, call service, format response
       ↓
Service / Use Case        ← Business logic: orchestration, validation, domain rules
       ↓
Repository / Gateway      ← Data access: DB queries, external API calls, file I/O
       ↓
Domain / Model            ← Pure data structures and domain types. No I/O. No framework imports.
```

- Handlers MUST NOT contain business logic.
- Services MUST NOT import HTTP frameworks, routers, or request/response types.
- Repositories MUST NOT contain business rules.
- Domain models MUST be plain data structures with no I/O, no framework dependencies, and no side effects.

## Dependency Injection

All dependencies must be injected, never imported as global singletons.

- Never instantiate dependencies inside the function that uses them.
- Define interfaces at the consumer side. Keep interfaces small (1-3 methods).
- Wire everything in one composition root.
- See lang-node.md / lang-python.md / lang-go.md for DI patterns and code examples.

## Interface-First Design

1. Define the interface/protocol first.
2. Write tests against the interface.
3. Then implement.

- Every external boundary MUST have an interface between it and business logic.
- Do NOT create interfaces for things that will never have a second implementation.

## Module Boundaries

Organize code by feature/domain, not by technical layer.

- Each feature module is self-contained.
- Cross-module communication goes through interfaces only.
- A module MUST NOT import another module's internal implementation.
- See the language file for the exact directory structure and file naming.

## How to Add a New Feature Module

Follow this exact sequence. Refer to the language file for specific file names:

```
1. Create the feature directory

2. Create files in this order:
   a. Domain types            ← Pure data structures (no dependencies)
   b. Repository interface    ← Data access interface + implementation
   c. Service                 ← Business logic (depends on repository interface)
   d. Handler / Controller    ← HTTP layer (depends on service interface)
   e. Tests                   ← At minimum: service layer tests

3. Wire dependencies in the composition root

4. Register routes
```

**Checklist before done:**
- [ ] Domain types have no I/O, no framework imports
- [ ] Service depends on interfaces, not concrete types
- [ ] Handler only parses request, calls service, formats response
- [ ] Tests cover service layer at minimum
- [ ] No cross-module imports of internal implementation

## Extension Point Design

Use when requirements suggest future variability. Do NOT add speculatively.

- Strategy Pattern — interchangeable algorithms
- Event / Hook Pattern — side effects without tight coupling
- Registry / Plugin Pattern — register implementations at startup
- Prefer simplest: Strategy > Event > Plugin.

## Config & Feature Flags

- Config loaded once at startup, validated, injected via DI as typed struct.
- Services never read env vars directly.
- Branch on feature flags, never on environment name.
