# Project & Operations Standards

## Project Structure

- Keep files under 250 lines. Split by responsibility if exceeded.
- One component / service / hook per file.
- Never commit build artifacts. Respect .gitignore.
- Colocate tests next to source.

## Git & CI/CD

- Never commit directly to main. All changes go through PRs.
- Use Conventional Commits: feat:, fix:, chore:, docs:, refactor:, test:, ci:.
- Use Semantic Versioning: major.minor.patch.
- Every PR must pass: lint, test, build.
- Do NOT commit unless the user explicitly asks.

## Docker-First Development

All services run in Docker. Use `docker compose` as the standard development environment.

### New Project Setup (Step-by-Step)

When starting a new project from scratch:

```
1. Create project directory and initialize git:
   mkdir <project-name> && cd <project-name> && git init

2. Create base files:
   a. .gitignore          ← Language-specific ignores + .env, node_modules, dist, etc.
   b. .env.example         ← All required env vars with placeholder values
   c. Dockerfile           ← Multi-stage build (see rules below)
   d. docker-compose.yml   ← App + all dependent services (DB, cache, etc.)
   e. Makefile             ← Wraps Docker commands (see below)

3. Create the application scaffold:
   a. Initialize the language project (go mod init / npm init / poetry init)
   b. Create src/ directory with feature-based structure (see architecture.md)
   c. Create first /health endpoint to validate the setup works

4. Verify the setup:
   docker compose up -d
   curl http://localhost:<port>/health  # Should return 200

5. Create initial commit:
   git add -A && git commit -m "feat: project scaffold with Docker setup"
```

### Makefile Template

Every project should have a `Makefile` with at least these targets:

```makefile
.PHONY: up down build test lint logs shell

up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

test:
	docker compose exec app make test-local

lint:
	docker compose exec app make lint-local

logs:
	docker compose logs -f app

shell:
	docker compose exec app bash
```

### Dockerfile Rules

- Use multi-stage builds. Build stage installs dependencies and compiles; runtime stage copies only artifacts.
- Run as non-root user (`USER appuser`).
- Include HEALTHCHECK.
- Do not copy .env, .git, node_modules, or dependency caches into the image.
- Pin base image versions (e.g., `node:20-slim`, not `node:latest`).

### docker-compose.yml Rules

- Define all dependent services (DB, Redis, etc.) so `docker compose up` is the only command needed.
- Use named volumes for data persistence.
- Use `.env` file for configuration. Provide `.env.example` with placeholder values.
- Expose ports only on localhost (e.g., `127.0.0.1:3000:3000`).

### Development Workflow

```
docker compose up -d          # Start all services
docker compose exec app bash  # Shell into the app container
docker compose logs -f app    # Tail logs
docker compose down           # Stop all services
```

### Running Tests in Docker

```
docker compose exec app make test     # Run tests inside container
docker compose exec app make lint     # Run linter inside container
```

Always verify that tests pass inside Docker, not just on host. The Docker environment is the source of truth.

## Observability

- Every service must have a /health endpoint.
- Use JSON structured logging with correlation/trace ID.
- Include basic metrics for new endpoints.

## Documentation

- Add docstrings when creating new modules.
- Update OpenAPI spec when modifying APIs.
- Suggest ADRs for architectural decisions.
- Keep README current.

## Dependencies

- Verify new dependencies are maintained and vulnerability-free.
- No dependencies for trivial functionality (<20 lines).
- Remove unused dependencies.
- Always use the project's lockfile.

## Configuration

- All config externalized via environment variables.
- No environment-specific values in source code.
- Respect local/staging/prod config separation.
