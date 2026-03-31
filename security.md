# Security Standards

These rules are mandatory. No exceptions.

- NEVER hardcode secrets, API keys, tokens, or passwords. Use environment variables or secret managers.
- NEVER write .env values into committed files. Always use .env.example as template.
- All user input MUST be validated and sanitized before processing.
- All authenticated endpoints MUST verify JWT/OAuth tokens.
- Use HTTPS for all external calls. No plain HTTP.
- When adding dependencies, check for known vulnerabilities.

## Security Checklist

Run this checklist before reporting any task as complete:

```
1. Secrets:     No hardcoded secrets, keys, or tokens in code or config files?
2. .env:        .env is in .gitignore? Only .env.example is committed?
3. Input:       All user input validated and sanitized? (query params, body, headers)
4. Auth:        Protected endpoints verify JWT/OAuth tokens?
5. SQL:         Using parameterized queries or ORM? No string concatenation in queries?
6. XSS:         User-generated content escaped before rendering in HTML?
7. HTTPS:       All external API calls use HTTPS?
8. Dependencies: New dependencies checked for known vulnerabilities?
9. Logs:        No secrets, tokens, or PII in log output?
10. Errors:     Error responses do not leak internal details (stack traces, DB schema)?
```

If any item fails, fix it before reporting completion. Do not skip.

## Container & Docker Security

- NEVER use `latest` tag for base images. Pin to specific versions (e.g., `node:20-alpine`, `python:3.12-slim`).
- ALWAYS run containers as a non-root user. Define `USER` in Dockerfile.
- ALWAYS include a `.dockerignore` to prevent `.env`, `.git`, and secrets from entering the build context.
- Use multi-stage builds — runtime image must not contain build tools, compilers, or package managers.
- Apply `no-new-privileges` security option to prevent privilege escalation.
- Use `read_only: true` in docker-compose to make the root filesystem read-only.
- Drop all Linux capabilities with `cap_drop: ALL`. Only add back specific ones if absolutely required.
- Set memory and PID limits to prevent resource exhaustion attacks.
- Scan images for CVEs with Trivy (or equivalent) in CI. Fail the pipeline on CRITICAL/HIGH findings.
- Never store secrets in Docker images or build args. Use runtime environment variables or secret managers.
- Expose ports only on `127.0.0.1` in development. In production, use a reverse proxy.

## MCP Server Security

- Prefer official vendor MCP servers over community forks.
- Use the minimum required permissions.
- Never store MCP credentials in committed files.
- If unsure whether an MCP server is safe, ask the user before proceeding.

### Serena MCP Server

Serena is the recommended MCP server for project understanding and code navigation. When configuring Serena:

- Use Serena in **read-only mode** by default for codebase exploration and comprehension.
- Only enable write capabilities when explicitly needed and approved by the user.
- Configure Serena's workspace scope to the current project only — do not grant access to parent directories or unrelated repos.
- Serena credentials and configuration belong in user-level MCP settings (e.g., `~/.claude/settings.json` or IDE MCP config), NOT in committed project files.
- Review Serena's permission scope periodically — revoke access that is no longer needed.
