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

Go — constructor injection:

```go
type OrderService struct {
    repo     OrderRepository   // interface, not concrete type
    notifier Notifier          // interface, not concrete type
}

func NewOrderService(repo OrderRepository, notifier Notifier) *OrderService {
    return &OrderService{repo: repo, notifier: notifier}
}
```

Python / FastAPI — Depends():

```python
class OrderRepository(Protocol):
    async def get_by_id(self, order_id: str) -> Order | None: ...

async def get_order(
    order_id: str,
    repo: OrderRepository = Depends(get_order_repo),
) -> Order:
    ...
```

- Never instantiate dependencies inside the function that uses them.
- In Go: define interfaces at the consumer side. Keep interfaces small (1-3 methods).
- In Python: use Protocol for structural typing. Use Depends() for FastAPI.
- Wire everything in one composition root: main.go (Go), main.py / app/dependencies.py (Python).

## Interface-First Design

1. Define the interface/protocol first.
2. Write tests against the interface.
3. Then implement.

- Every external boundary MUST have an interface between it and business logic.
- Do NOT create interfaces for things that will never have a second implementation.

## Module Boundaries

Organize code by feature/domain, not by technical layer.

```
src/
├── order/
│   ├── handler.go / router.py
│   ├── service.go / service.py
│   ├── repository.go / repository.py
│   ├── model.go / model.py
│   └── order_test.go / test_service.py
├── inventory/
│   └── ...
└── shared/
    ├── config/
    ├── middleware/
    └── errors/
```

- Each feature module is self-contained.
- Cross-module communication goes through interfaces only.
- A module MUST NOT import another module's internal implementation.

## How to Add a New Feature Module

Follow this exact sequence when creating a new feature:

```
1. Create the feature directory:
   src/<feature-name>/

2. Create files in this order:
   a. model.go / model.py / types.ts       ← Domain types first (no dependencies)
   b. repository.go / repository.py / repo.ts ← Data access interface + implementation
   c. service.go / service.py / service.ts   ← Business logic (depends on repository interface)
   d. handler.go / router.py / controller.ts ← HTTP layer (depends on service interface)
   e. *_test.go / test_*.py / *.test.ts      ← Tests for service layer (at minimum)

3. Wire dependencies in the composition root:
   - main.go / main.py / app/dependencies.py / src/index.ts

4. Register routes in the router/handler setup.

5. Update docs if this introduces a new pattern or domain concept.
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
