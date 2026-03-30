# AI Development Standards v4.2

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Maintainer:** Sammy Lin | **Last Updated:** 2026-03-30

## Onboarding Prompt

Paste the following prompt in any AI coding tool (Claude Code, Kiro, Cursor, Windsurf, etc.) to automatically fetch the standards and set them up in your project:

```
Fetch and read the following files as the development standards for this project:

- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/code-quality.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/architecture.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/security.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/project-ops.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/ai-behavior.md

Then, based on the tool you are running in, create the appropriate config file:

- Claude Code → create CLAUDE.md
- Kiro → create .kiro/steering/standards.md
- Cursor → create .cursorrules
- Windsurf → create .windsurfrules
- Other tools → create the equivalent config file

Config file format:
1. Add "source: https://github.com/SammyLin/aicoding" at the top
2. Write all standards content below, preserving the original structure
3. If a config file already exists, append the standards after the existing content

When done, report which files you created.
```

## Standards

| File | Description |
|------|-------------|
| [code-quality.md](code-quality.md) | Code quality, testing, error handling, typing |
| [architecture.md](architecture.md) | Layered architecture, DI, module boundaries |
| [security.md](security.md) | Secrets, input validation, MCP server rules |
| [project-ops.md](project-ops.md) | Project structure, git, CI/CD, observability |
| [ai-behavior.md](ai-behavior.md) | AI agent behavior rules and quick reference |

## How It Works

1. AI agent reads these files at session start
2. Rules are applied as constraints during code generation
3. Agent follows verification sequence after each implementation

## License

MIT
