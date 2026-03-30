# AI Development Standards v4.3

Standardized rules for AI coding agents. Host publicly so any AI agent can read and apply these standards via onboarding prompt.

**Core Philosophy:** One feature at a time. Verify before moving on. No overengineering.

**Maintainer:** Sammy Lin | **Last Updated:** 2026-03-30

## Onboarding Prompts

### Claude Code

```
Fetch and read the following files as the development standards for this project:

- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/code-quality.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/architecture.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/security.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/project-ops.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/ai-behavior.md

Create a CLAUDE.md file in the project root with all the standards content.
Add "source: https://github.com/SammyLin/aicoding" at the top.
If CLAUDE.md already exists, append the standards after the existing content.

IMPORTANT: Before starting any coding task:
1. Read CLAUDE.md to understand the project standards
2. List your implementation steps and confirm the approach with the user
3. Implement one feature at a time, verify after each change
4. Report completion with what was done and any decisions made
```

### Kiro

```
Fetch and read the following files as the development standards for this project:

- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/code-quality.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/architecture.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/security.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/project-ops.md
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/ai-behavior.md

Create .kiro/steering/standards.md with all the standards content.
Add "source: https://github.com/SammyLin/aicoding" at the top.
If the file already exists, append the standards after the existing content.

IMPORTANT: Before starting any coding task:
1. Read the standards to understand project conventions
2. List your implementation steps and confirm the approach with the user
3. Implement one feature at a time, verify after each change
4. Report completion with what was done and any decisions made
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

1. Copy the prompt for your tool above
2. Paste it in a new session at your project root
3. AI fetches the standards and creates the config file
4. Standards are applied as constraints during code generation

## License

MIT
