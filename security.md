# Security Standards

These rules are mandatory. No exceptions.

- NEVER hardcode secrets, API keys, tokens, or passwords. Use environment variables or secret managers.
- NEVER write .env values into committed files. Always use .env.example as template.
- All user input MUST be validated and sanitized before processing.
- All authenticated endpoints MUST verify JWT/OAuth tokens.
- Use HTTPS for all external calls. No plain HTTP.
- When adding dependencies, check for known vulnerabilities.

## MCP Server Security

- Prefer official vendor MCP servers over community forks.
- Use the minimum required permissions.
- Never store MCP credentials in committed files.
- If unsure whether an MCP server is safe, ask the user before proceeding.
