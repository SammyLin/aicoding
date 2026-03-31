# Project & Operations Standards

## Project Structure

- Keep files under 250 lines. Split by responsibility if exceeded.
- One component / service / hook per file.
- Never commit build artifacts. Respect .gitignore.
- Colocate tests next to source.

## Git Commit Rules

All commit messages MUST be written in English. Follow Conventional Commits strictly.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Rules

1. **Language:** English only. No exceptions.
2. **Type:** One of: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`, `build`, `perf`.
3. **Subject line:**
   - Use imperative mood: "add feature", not "added feature" or "adds feature"
   - Lowercase after the colon: `feat: add user auth`, not `feat: Add user auth`
   - Max 50 characters. No period at the end.
   - Focus on WHAT changed, not HOW.
4. **Body** (optional but recommended for non-trivial changes):
   - Separate from subject with a blank line.
   - Wrap at 72 characters per line.
   - Explain WHY the change was made, not what (the diff shows what).
   - Reference issue numbers: `Fixes #123` or `Closes #456`.
5. **Breaking changes:** Add `BREAKING CHANGE:` in the footer or `!` after type: `feat!: remove legacy API`.
6. **Scope** (optional): Module or feature name: `feat(auth): add JWT refresh`.

### Examples

```
feat(order): add inventory check before order creation

Prevent orders when stock is insufficient. The service layer now
validates inventory before persisting the order.

Closes #42
```

```
fix: handle null response from payment gateway

The gateway returns null instead of an error object on timeout.
Added explicit null check with retry logic.
```

```
refactor(auth): extract token validation to shared middleware
```

### Enforcement

- Set up commitlint + husky in every project to enforce format via git hooks.
- CI should also validate commit messages on PRs.
- If commitlint is not yet set up, set it up as part of project initialization.

```
# Node project setup:
pnpm add -D @commitlint/cli @commitlint/config-conventional husky
echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
pnpm exec husky init
echo "pnpm exec commitlint --edit \$1" > .husky/commit-msg
```

## Git Workflow

- Never commit directly to main. All changes go through PRs.
- Use Semantic Versioning: major.minor.patch.
- Every PR must pass: lint, test, build, commitlint.
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
   c. Dockerfile           ← Multi-stage build (see lang-*.md for template)
   d. docker-compose.yml   ← App + all dependent services (DB, cache, etc.)
   e. Makefile             ← Wraps Docker commands (see below)

3. Create the application scaffold (refer to the language-specific rules):
   - Node/TypeScript → see lang-node.md
   - Python          → see lang-python.md
   - Go              → see lang-go.md

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
- Run as non-root user.
- Include HEALTHCHECK.
- Do not copy .env, .git, or dependency caches into the image.
- Pin base image versions (e.g., `node:20-slim`, not `node:latest`).
- See lang-node.md / lang-python.md / lang-go.md for Dockerfile templates.

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

## Package Manager & Linter

Language-specific package managers, linters, and formatters are defined in the language files:

| Language | File | Package Manager | Linter / Formatter |
|----------|------|----------------|-------------------|
| Node / TypeScript | lang-node.md | pnpm | ESLint + Prettier |
| Python | lang-python.md | uv | ruff |
| Go | lang-go.md | go mod | golangci-lint + gofmt |

### Rules (all languages)

- Every project MUST have a linter and formatter from the first commit.
- Always commit the lockfile. Never .gitignore it.
- Never mix package managers in the same project.
- Do NOT disable linter rules to bypass errors. Fix the code.
- Do NOT add suppression comments without user approval.
- If the project already has a package manager or linter, keep using it.
- Linter + formatter MUST run inside Docker via `make lint`.

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
- Install via the project's package manager. Never use npm, pip, or yarn directly.

## Configuration

- All config externalized via environment variables.
- No environment-specific values in source code.
- Respect local/staging/prod config separation.
