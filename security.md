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

## MCP Server Security

- Prefer official vendor MCP servers over community forks.
- Use the minimum required permissions.
- Never store MCP credentials in committed files.
- If unsure whether an MCP server is safe, ask the user before proceeding.
