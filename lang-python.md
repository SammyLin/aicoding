# Python Standards

This file contains all Python specific conventions. Apply these rules when working in a Python project.

## Package Manager: uv

```
1. uv init
2. Use uv for all operations:
   uv add <pkg> / uv add --dev <pkg> / uv run <command> / uv sync
3. Commit uv.lock and pyproject.toml.
```

- Never use pip, poetry, or pipenv. If the project already uses them, ask the user before migrating.
- Lockfile: `uv.lock` — always commit.

## Linter & Formatter: ruff

```
1. Install: uv add --dev ruff
2. Add [tool.ruff] section to pyproject.toml:
   [tool.ruff]
   line-length = 120
   [tool.ruff.lint]
   select = ["E", "F", "I", "N", "W", "UP", "B", "SIM"]
3. Add to Makefile:
   lint-local: uv run ruff check . && uv run ruff format --check .
   lint-fix: uv run ruff check --fix . && uv run ruff format .
4. Verify: uv run ruff check . && uv run ruff format --check .
```

## Naming Conventions

- Files / Functions / Variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Test files: `test_*.py`, colocated next to source

## File Structure (feature-based)

```
src/
├── order/
│   ├── model.py            ← Domain types (Pydantic models, dataclasses)
│   ├── repository.py       ← Data access (Protocol + implementation)
│   ├── service.py          ← Business logic
│   ├── router.py           ← HTTP handler (FastAPI router)
│   ├── test_service.py     ← Tests (colocated)
│   └── __init__.py
├── shared/
│   ├── config/
│   ├── middleware/
│   └── errors/
└── main.py                 ← Composition root: wire DI, register routers
```

## How to Add an API Endpoint

```
1. Define models       → src/<feature>/model.py (Pydantic schema)
2. Write service test  → src/<feature>/test_service.py
3. Implement service   → src/<feature>/service.py
4. Run test — confirm pass
5. Write router        → src/<feature>/router.py (thin: parse req → call service → format res)
6. Register route      → src/main.py (app.include_router)
7. Run: uv run ruff check . && uv run pytest
8. Test manually: curl http://localhost:8000/api/<endpoint>
```

## Dependency Injection (FastAPI)

Use `Depends()` with Protocol for structural typing.

```python
from typing import Protocol
from fastapi import Depends


class OrderRepository(Protocol):
    async def get_by_id(self, order_id: str) -> Order | None: ...


class OrderService:
    def __init__(self, repo: OrderRepository) -> None:
        self.repo = repo

    async def get_order(self, order_id: str) -> Order:
        order = await self.repo.get_by_id(order_id)
        if not order:
            raise NotFoundError(f"Order {order_id} not found")
        return order


# In router, wire via Depends()
async def get_order(
    order_id: str,
    service: OrderService = Depends(get_order_service),
) -> Order:
    return await service.get_order(order_id)
```

- Wire everything in one composition root: `main.py` or `app/dependencies.py`.
- Use Protocol for structural typing. Keep interfaces small.

## Error Handling

- Use domain-specific exception classes.
- Raise from service layer. Catch and convert to HTTP at router layer only.
- Always wrap with context: what operation failed, why, and relevant IDs.

```python
class AppError(Exception):
    def __init__(self, message: str, status_code: int = 500) -> None:
        super().__init__(message)
        self.status_code = status_code


class NotFoundError(AppError):
    def __init__(self, message: str) -> None:
        super().__init__(message, status_code=404)
```

## Types & Validation

- Type hints on ALL function signatures. No untyped functions.
- Use Pydantic for runtime validation at boundaries (API input, external data).
- Use Protocol for structural typing (interfaces).
- Use `from __future__ import annotations` for forward references.
- Run type checker: `uv run mypy .` (if mypy configured) or `uv run pyright .`

## Testing

- Framework: pytest.
- Run: `uv run pytest`
- Mock external deps with `pytest-mock` or dependency injection.
- Test naming: `test_create_order_returns_error_when_inventory_empty`
- Use `@pytest.fixture` for shared test setup.

## i18n (Internationalization)

If the project requires multilingual support, choose a framework based on your stack:

| Framework | Best For | Key Trait |
|---|---|---|
| **Babel** | Flask / general web apps | CLDR-based locale data (dates, numbers, currencies), Jinja2 integration |
| **django.utils.translation** | Django projects | Built-in, deep Django integration, `makemessages` CLI |
| **gettext** (stdlib) | CLI tools / zero-dependency | Python built-in, POSIX standard, .po/.mo files |
| **python-i18n** | Small projects (YAML/JSON) | Simple key-value approach, Rails-like API |

**Default recommendation:** `Babel` for general projects, Django built-in for Django projects.

```
1. Install the chosen i18n library (Babel: uv add Babel flask-babel).
2. Create a locale directory: src/locales/{en,zh_TW,...}/LC_MESSAGES/
3. Extract all user-facing strings into translation keys from the start.
4. Never hardcode user-facing strings — always use the translation function (_() or gettext()).
5. Set up locale negotiation (Accept-Language header or user preference).
6. Use pybabel extract (or makemessages for Django) to keep translation catalogs in sync.
```

## Dockerfile

```dockerfile
FROM python:3.12-slim AS build
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev
COPY . .

FROM python:3.12-slim AS runtime
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
WORKDIR /app
COPY --from=build /app /app
RUN useradd -r appuser
USER appuser
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["uv", "run", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```
