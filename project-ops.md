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
.PHONY: up down build test lint logs shell scan

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
	docker compose exec app sh

scan:
	trivy image $$(docker compose images -q app)
```

### .dockerignore (Required)

Every project with a Dockerfile MUST have a `.dockerignore` to prevent secrets and bloat from entering the build context:

```
.git
.gitignore
.env
.env.*
!.env.example
node_modules
dist
__pycache__
*.pyc
.venv
.pytest_cache
.mypy_cache
.ruff_cache
coverage
*.md
LICENSE
.vscode
.idea
docker-compose*.yml
Makefile
```

### Dockerfile Rules

- Use multi-stage builds. Build stage installs dependencies and compiles; runtime stage copies only artifacts.
- Run as non-root user. Never run containers as root in production.
- Include `HEALTHCHECK` with explicit `--interval`, `--timeout`, `--start-period`, and `--retries`.
- Do not copy `.env`, `.git`, or dependency caches into the image.
- Pin base image versions (e.g., `node:20-alpine`, not `node:latest`). For critical workloads, pin to SHA digest.
- Prefer minimal base images: `alpine` > `slim` > full. For Go, prefer `distroless`.
- Use `--ignore-scripts` (Node) or equivalent to prevent supply-chain attacks during install.
- Strip unnecessary files from runtime stage — only copy what the app needs to run.
- Set `EXPOSE` to document which ports the container listens on.
- See lang-node.md / lang-python.md / lang-go.md for Dockerfile templates.

### Image Scanning

Scan images for vulnerabilities before deploying. Run in CI and locally:

```bash
# Using Trivy (recommended)
trivy image <image-name>:<tag>

# Fail CI if critical/high vulnerabilities found
trivy image --exit-code 1 --severity CRITICAL,HIGH <image-name>:<tag>
```

Add to `Makefile`:

```makefile
scan:
	trivy image $$(docker compose images -q app)
```

### docker-compose.yml Rules

- Define all dependent services (DB, Redis, etc.) so `docker compose up` is the only command needed.
- Use named volumes for data persistence.
- Use `.env` file for configuration. Provide `.env.example` with placeholder values.
- Expose ports only on localhost (e.g., `127.0.0.1:3000:3000`).
- Apply security hardening to all services:

```yaml
services:
  app:
    build: .
    ports:
      - "127.0.0.1:3000:3000"
    security_opt:
      - no-new-privileges:true    # Prevent privilege escalation
    read_only: true                # Read-only root filesystem
    tmpfs:
      - /tmp                      # Writable temp dir if needed
    cap_drop:
      - ALL                       # Drop all Linux capabilities
    mem_limit: 512m               # Prevent OOM from taking down host
    pids_limit: 100               # Prevent fork bombs
    restart: unless-stopped
    env_file:
      - .env
```

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

## Git Commit Frequency

Commit early and often. Small, frequent commits are always better than one giant commit.

### Rules

1. **Commit after each meaningful change.** Completed a function? Commit. Fixed a bug? Commit. Added a test? Commit. Do not accumulate unrelated changes into a single commit.
2. **Each commit should be atomic** — it represents one logical change that can be understood in isolation.
3. **Never wait until a feature is "fully done" to commit.** Break the work into incremental commits:
   - Scaffold / boilerplate → commit
   - Core logic → commit
   - Tests → commit
   - Wiring / integration → commit
4. **If you've been working for more than 15 minutes without committing, stop and commit what you have.**
5. **Prefer 10 small commits over 1 large commit.** Reviewers, bisect, and rollback all benefit from granularity.
6. **WIP commits are acceptable** on feature branches: `wip: add partial order validation logic`. Squash before merging to main if needed.

### Why This Matters

- Small commits make `git bisect` effective for finding bugs.
- Small commits make code review faster and more focused.
- Small commits reduce merge conflict size and complexity.
- Small commits provide natural checkpoints — if something breaks, you lose less work.
- AI agents especially benefit: frequent commits create recovery points for long-running tasks.

## Observability

Every service MUST be observable from day one. Do not add observability as an afterthought — it is a core requirement alongside business logic.

### Health & Readiness

- Every service must have a `/health` endpoint (liveness check).
- Add a `/ready` endpoint for readiness checks (dependencies up, DB connected, etc.).
- Health checks should return structured JSON: `{ "status": "ok", "version": "1.2.3", "uptime": 12345 }`.

### Structured Logging

- Use JSON structured logging in all services. No `console.log` or `print` in production code.
- Every log entry MUST include: `timestamp`, `level`, `message`, `service`, `correlation_id` (or `trace_id`).
- Use log levels correctly:
  - `error`: Something failed and needs attention.
  - `warn`: Something unexpected but recoverable.
  - `info`: Key business events (user created, order placed, payment processed).
  - `debug`: Detailed diagnostic info (disabled in production by default).
- Log at business-critical points:
  - Request received / response sent (with duration).
  - External API calls (start, end, duration, status).
  - Database queries (in debug mode, with duration).
  - Authentication events (login, logout, token refresh, failures).
  - Error and exception handling paths.
- NEVER log secrets, tokens, passwords, or PII. Mask sensitive fields.

### Metrics & Counters (Prometheus)

Every service MUST expose metrics in Prometheus format at `/metrics`. Place counters and gauges at critical points in the application.

#### Required Metrics

| Metric Type | Name Pattern | Where to Place |
|-------------|-------------|----------------|
| **Counter** | `http_requests_total{method, path, status}` | HTTP middleware |
| **Histogram** | `http_request_duration_seconds{method, path}` | HTTP middleware |
| **Counter** | `<domain>_operations_total{operation, status}` | Service layer (e.g., `orders_operations_total{operation="create", status="success"}`) |
| **Counter** | `external_api_calls_total{service, endpoint, status}` | External API client |
| **Histogram** | `external_api_duration_seconds{service, endpoint}` | External API client |
| **Gauge** | `db_connections_active` | Database connection pool |
| **Counter** | `errors_total{type, layer}` | Error handling middleware |
| **Counter** | `auth_events_total{event}` | Auth middleware (`login_success`, `login_failure`, `token_expired`) |

#### Instrumentation Rules

1. **Add counters at every business-critical code path.** If it matters to the business, measure it.
2. **Use labels wisely.** Avoid high-cardinality labels (e.g., user IDs, request IDs as label values).
3. **Instrument at the boundaries:** HTTP handlers, service methods, external calls, DB queries.
4. **Use histograms for latency**, not averages. Histograms give you percentiles (p50, p95, p99).
5. **Name metrics consistently:** `<namespace>_<subsystem>_<name>_<unit>` (e.g., `myapp_orders_created_total`).

#### Language-Specific Libraries

| Language | Prometheus Library | Logging Library |
|----------|-------------------|-----------------|
| Node/TypeScript | `prom-client` | `pino` (structured JSON) |
| Python | `prometheus-client` | `structlog` |
| Go | `prometheus/client_golang` | `slog` (stdlib) or `zerolog` |

### Dashboards & Visualization (Grafana)

- Every service SHOULD have a Grafana dashboard defined as code (JSON or Grafonnet).
- Store dashboard definitions in `infra/grafana/dashboards/` or `monitoring/dashboards/`.
- Minimum dashboard panels:
  - Request rate (requests/second)
  - Error rate (errors/second, error percentage)
  - Latency (p50, p95, p99)
  - Active connections / resource utilization
- Use the RED method (Rate, Errors, Duration) for service dashboards.
- Use the USE method (Utilization, Saturation, Errors) for infrastructure dashboards.

### docker-compose Observability Stack

When setting up a new project, include observability services in `docker-compose.yml`:

```yaml
services:
  prometheus:
    image: prom/prometheus:v2.51.0
    volumes:
      - ./infra/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "127.0.0.1:9090:9090"

  grafana:
    image: grafana/grafana:10.4.0
    volumes:
      - ./infra/grafana/dashboards:/var/lib/grafana/dashboards
      - ./infra/grafana/provisioning:/etc/grafana/provisioning
      - grafana_data:/var/lib/grafana
    ports:
      - "127.0.0.1:3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_ADMIN_PASSWORD:-admin}

volumes:
  prometheus_data:
  grafana_data:
```

### Alerting

- Define alerts in Prometheus alerting rules or Grafana alert rules.
- At minimum, alert on:
  - Error rate > threshold (e.g., >5% of requests return 5xx for 5 minutes).
  - Latency spike (e.g., p99 > 2s for 5 minutes).
  - Service down (health check failing for >1 minute).
- Store alert rules as code alongside the service.

### Tracing (Optional but Recommended)

- For multi-service architectures, add distributed tracing via OpenTelemetry.
- Propagate `trace_id` across service boundaries.
- Export traces to Jaeger, Zipkin, or Grafana Tempo.
- At minimum, create spans for: incoming HTTP requests, outgoing HTTP/gRPC calls, database queries.

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
