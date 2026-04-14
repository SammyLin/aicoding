# aicoding repo

Team AI-coding standards installer for bootstrapping new projects. Built on **progressive disclosure**: core rules always loaded, language rules gated by `paths:`, situational rules invoked as Skills, plus Agent + Commands + Hooks to support the 5-step flow.

## Repo Layout

```
Core rules (always installed to .claude/rules/):
  ai-behavior.md         — 5-step flow, commit frequency
  code-quality.md        — TDD, error handling, typing
  architecture.md        — Layered architecture, DI

Language rules (auto-detected; have `paths:` frontmatter, loaded only when relevant files are in context):
  lang-node.md           — when package.json exists
  lang-python.md         — when pyproject.toml / requirements.txt exists
  lang-go.md             — when go.mod exists
  lang-frontend.md       — when .tsx / vite.config / React is present

Situational rules (wrapped as Skills, invoked by the agent on demand):
  security.md            → .claude/skills/security-check/SKILL.md
  project-ops.md         → .claude/skills/infra-ops/SKILL.md
  harness-engineering.md → .claude/skills/harness-review/SKILL.md
  agent-browser-skill.md → .claude/skills/browser-verify/SKILL.md

Agent + Commands (support Verify / Commit flow):
  agents/code-reviewer.md    → .claude/agents/code-reviewer.md
  commands/commit.md         → .claude/commands/commit.md
  commands/review.md         → .claude/commands/review.md

Hooks + Settings (automation and permissions):
  hooks/auto-format.sh       → .claude/hooks/auto-format.sh
  hooks/secret-guard.sh      → .claude/hooks/secret-guard.sh
  settings.json              → .claude/settings.json

Other:
  setup.sh                   — Installer (language detection, Kiro format conversion)
  docs/                      — Knowledge base (not installed to target projects)
```

## 5-Layer Design

| Layer | Location | When Loaded | Content |
|-------|----------|-------------|---------|
| 1. Core | `.claude/rules/` | Always | Needed for every task |
| 2. Language | `.claude/rules/` | When files match `paths:` | Language conventions |
| 3. Skills | `.claude/skills/` | Claude decides | Security / ops / harness / browser |
| 4. Agent + Commands | `.claude/agents/` + `.claude/commands/` | User invocation | Verify / Commit flow |
| 5. Hooks + Settings | `.claude/hooks/` + `.claude/settings.json` | Event-triggered | Auto-format, block risky commands |

## Kiro CLI Mapping

Kiro CLI's format doesn't fully overlap with Claude Code. `setup.sh` handles the conversions automatically:

| Claude Code | Kiro CLI | What setup.sh does |
|-------------|----------|--------------------|
| `paths:` YAML array | `inclusion: fileMatch` + `fileMatchPattern: "a\|b\|c"` | Auto-converts |
| Agent markdown | Agent JSON | Parses frontmatter + body, emits JSON |
| Commands / Hooks / settings.json | — | ❌ Not supported by Kiro CLI — skipped |

## Editing Principles

- **Core rules**: keep concise, high value density. These are ALWAYS in context.
- **Language rules**: self-contained per language. Scoped by `paths:`. Detection logic lives in `setup.sh::detect_languages()`.
- **Situational rules**: source files (security.md etc.) are wrapped into SKILL.md with frontmatter by setup.sh.
- **Skill description** (~250 chars) is the trigger — phrase it the way a user would naturally ask.
- **Agent + Commands**: **restraint principle** — only one agent + two commands, mapping to Verify + Commit in the 5-step flow. More than that is a "persona zoo."
- **Hooks**: only ship the two language-agnostic, low-risk ones (auto-format, secret-guard).
- **settings.json**: team-level permission consensus — personal preferences don't belong here.

## Adding a New Item

### Adding a Skill

1. Write the source file `foo.md`.
2. Add to `setup.sh` arrays: `SKILL_NAMES` / `SKILL_SOURCES` / `SKILL_DESCRIPTIONS`.

### Adding a Language

1. Write `lang-xxx.md` with a `paths:` frontmatter at the top.
2. Add to `setup.sh` arrays: `LANG_FILES` / `LANG_DETECT` / `LANG_LABELS` / `LANG_DESCRIPTIONS` / `LANG_KIRO_PATTERN`.

### Adding an Agent / Command / Hook

**First ask: is this really necessary?** Watch for anti-patterns like persona zoos, filler commands, or running the full test suite on every edit.

If truly needed:

1. Place the file under `agents/` / `commands/` / `hooks/`.
2. Add to `setup.sh` arrays: `AGENT_FILES` / `COMMAND_FILES` / `HOOK_FILES`.

## Testing

```bash
# Start a local HTTP server that serves this repo
python3 -m http.server 8765 --bind 127.0.0.1 &

# Simulate a Go project in a temp dir
mkdir -p /tmp/test && cd /tmp/test && touch go.mod
BASE_URL=http://127.0.0.1:8765 bash <(curl -s http://127.0.0.1:8765/setup.sh)

# Inspect the result
find /tmp/test -type f | sort
```

`setup.sh` honors a `BASE_URL` environment variable override for local testing.

## Language Policy

- **AI-facing files** (rules, skills, agents, commands, hooks, this CLAUDE.md, `setup.sh` output) are written in **English**.
- **Human-facing docs** (README, `docs/`) may be bilingual. The primary README is English; `README.zh-TW.md` is the Traditional Chinese mirror.
- **When editing README, update both `README.md` and `README.zh-TW.md`** — they must stay in sync.
