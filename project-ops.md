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

## Container

- Use multi-stage builds.
- Run as non-root user.
- Include HEALTHCHECK.
- Do not copy .env, .git, or dependency caches into the image.

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
