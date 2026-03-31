# AI Development Standards v4.4

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
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/harness-engineering.md

Set up the following structure (keep CLAUDE.md under 200 lines):

1. Create CLAUDE.md in the project root as a short entry file (table of contents):
   - Add "source: https://github.com/SammyLin/aicoding" at the top
   - Summarize core philosophy and key rules (one feature at a time, verify before moving on, no overengineering)
   - List each standard topic as a one-line summary with pointer: "See .claude/rules/<name>.md for details"
   - Include the "Before starting any coding task" checklist

2. Create .claude/rules/ directory with one file per standard:
   - .claude/rules/code-quality.md    ← from code-quality.md
   - .claude/rules/architecture.md    ← from architecture.md
   - .claude/rules/security.md        ← from security.md
   - .claude/rules/project-ops.md     ← from project-ops.md
   - .claude/rules/ai-behavior.md     ← from ai-behavior.md
   - .claude/rules/harness-engineering.md ← from harness-engineering.md

If CLAUDE.md already exists, preserve existing project-specific content and add the standards structure.

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
- https://raw.githubusercontent.com/SammyLin/aicoding/refs/heads/main/harness-engineering.md

Set up the following structure (one topic per file, keep each file focused):

1. Create .kiro/steering/standards.md as a short entry file (table of contents):
   - Add "source: https://github.com/SammyLin/aicoding" at the top
   - Summarize core philosophy and key rules
   - List each standard topic as a one-line summary with pointer to the detailed file

2. Create one steering file per standard:
   - .kiro/steering/code-quality.md    ← from code-quality.md
   - .kiro/steering/architecture.md    ← from architecture.md
   - .kiro/steering/security.md        ← from security.md
   - .kiro/steering/project-ops.md     ← from project-ops.md
   - .kiro/steering/ai-behavior.md     ← from ai-behavior.md
   - .kiro/steering/harness-engineering.md ← from harness-engineering.md

If the files already exist, preserve existing project-specific content and add the standards.

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
| [harness-engineering.md](harness-engineering.md) | Harness engineering: docs structure, guardrails, feedback loops |

## How It Works

1. Copy the prompt for your tool above
2. Paste it in a new session at your project root
3. AI fetches the standards and creates the config file
4. Standards are applied as constraints during code generation

## License

MIT
