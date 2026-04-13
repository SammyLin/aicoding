# aicoding repo

AI coding standards with **progressive disclosure**: core rules always loaded, language rules auto-detected, situational rules as Skills (agent decides when to read).

## Repo Structure

```
Core rules (always installed):
  ai-behavior.md         — 5-step flow, commit frequency
  code-quality.md        — TDD, error handling, typing
  architecture.md        — Layered architecture, DI

Language rules (auto-detected, only relevant ones installed):
  lang-node.md           — installed if package.json exists
  lang-python.md         — installed if pyproject.toml exists
  lang-go.md             — installed if go.mod exists
  lang-frontend.md       — installed if .tsx or vite.config exists

Situational rules (installed as Skills, agent-invoked):
  security.md            → .claude/skills/security-check/SKILL.md
  project-ops.md         → .claude/skills/infra-ops/SKILL.md
  harness-engineering.md → .claude/skills/harness-review/SKILL.md
  agent-browser-skill.md → .claude/skills/browser-verify/SKILL.md

Other:
  setup.sh               — Installer with auto-detection
  docs/                  — Knowledge base articles (not installed into projects)
```

## 3-Layer Design

| Layer | Where | Loading | Content |
|-------|-------|---------|---------|
| Core | `.claude/rules/` | Always | Every task needs these |
| Language | `.claude/rules/` | Always, but only installed if detected | Per-stack conventions |
| Skills | `.claude/skills/` | Agent decides | Security, ops, harness, browser |

## When Editing

- Core rules: keep short, high-value. These are ALWAYS in context.
- Lang rules: self-contained per language. Auto-detect logic in `setup.sh` `detect_languages()`.
- Situational rules: source files (security.md etc) get wrapped into SKILL.md with frontmatter by setup.sh.
- Skills description (~250 chars) is the trigger — write it as users would naturally ask.
- To add a new Skill: add to SKILL_NAMES/SKILL_SOURCES/SKILL_DESCRIPTIONS arrays in setup.sh.
- Test: `bash setup.sh` in a project with go.mod — should only install lang-go.md.
