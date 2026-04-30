# rigging repo

Team AI-coding standards installer for bootstrapping new projects. Built on **progressive disclosure**: core rules always loaded, language rules gated by `paths:`, situational rules invoked as Skills, plus Agent + Commands + Hooks to support the 5-step flow.

## Repo Layout

The source layout mirrors the install target 1:1 — what you see here is what gets deployed to `.claude/`.

```
rules/                       → .claude/rules/
  ai-behavior.md             — 5-step flow, commit frequency
  code-quality.md            — TDD, error handling, typing
  architecture.md            — Layered architecture, DI
  lang-node.md               — auto-detected by package.json; has paths: frontmatter
  lang-python.md             — auto-detected by pyproject.toml / requirements.txt
  lang-go.md                 — auto-detected by go.mod
  lang-frontend.md           — auto-detected by .tsx / vite.config / React

skills/                      → .claude/skills/<name>/SKILL.md (wrapped by setup.sh)
  security.md                → security-check
  project-ops.md             → infra-ops
  harness-engineering.md     → harness-review
  agent-browser-skill.md     → browser-verify

agents/                      → .claude/agents/
  code-reviewer.md           — subagent for the Verify step

commands/                    → .claude/commands/
  commit.md                  — /commit
  review.md                  — /review

hooks/                       → .claude/hooks/
  auto-format.sh             — PostToolUse Edit/Write
  secret-guard.sh            — PreToolUse Bash

settings.json                → .claude/settings.json
setup.sh                     — Installer (language detection, Kiro format conversion)
docs/                        — Knowledge base (not installed to target projects)
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

1. Write the source file `skills/foo.md`.
2. Add to `setup.sh` arrays: `SKILL_NAMES` / `SKILL_SOURCES` / `SKILL_DESCRIPTIONS`.

### Adding a Language

1. Write `rules/lang-xxx.md` with a `paths:` frontmatter at the top.
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
