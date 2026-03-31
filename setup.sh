#!/usr/bin/env bash
set -euo pipefail

# AI Development Standards Setup
# Usage:
#   Claude Code: curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
#   Kiro:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
#   Both:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all

BASE_URL="https://raw.githubusercontent.com/SammyLin/aicoding/main"
SOURCE="https://github.com/SammyLin/aicoding"
INSTALLED_AT="$(date +%Y-%m-%d)"

FILES=(
  "code-quality.md"
  "architecture.md"
  "security.md"
  "project-ops.md"
  "ai-behavior.md"
  "harness-engineering.md"
  "lang-node.md"
  "lang-python.md"
  "lang-go.md"
  "lang-frontend.md"
)

DESCRIPTIONS=(
  "Code quality, testing, error handling, typing"
  "Layered architecture, DI, module boundaries"
  "Secrets, input validation, MCP/Serena server rules"
  "Project structure, Docker, git, commit frequency, Prometheus/Grafana observability"
  "AI agent behavior, commit frequency, MCP/Serena usage, observability awareness"
  "Harness engineering: docs structure, guardrails, feedback loops"
  "Node/TypeScript: pnpm, ESLint, Prettier, Zod, vitest"
  "Python: uv, ruff, FastAPI, Pydantic, pytest"
  "Go: go mod, golangci-lint, constructor DI, table-driven tests"
  "Frontend: React, component design, state management, a11y, testing-library"
)

# --- Parse args ---
TARGET="claude"
for arg in "$@"; do
  case "$arg" in
    --kiro)   TARGET="kiro" ;;
    --all)    TARGET="all" ;;
    --claude) TARGET="claude" ;;
  esac
done

# Track which files were successfully downloaded
DOWNLOADED=()

# --- Download standards into a target directory ---
download_standards() {
  local dir="$1"
  mkdir -p "$dir"
  DOWNLOADED=()
  echo "Downloading standards to $dir/ ..."
  for file in "${FILES[@]}"; do
    if curl -fsSL "$BASE_URL/$file" -o "$dir/$file" 2>/dev/null; then
      echo "  ✓ $file"
      DOWNLOADED+=("$file")
    else
      echo "  ✗ $file (not found, skipping)"
      rm -f "$dir/$file"
    fi
  done
}

# --- Create symbolic links from one directory to another ---
link_standards() {
  local source_dir="$1" # .claude/rules
  local target_dir="$2" # .kiro/steering
  mkdir -p "$target_dir"
  echo "Creating symbolic links in $target_dir/ -> $source_dir/ ..."
  for file in "${DOWNLOADED[@]}"; do
    # 既然專案目錄結構固定，直接手動指定相對路徑回到根目錄
    # 這是最通用的做法，不依賴 realpath 指令
    local rel_path="../../$source_dir/$file"
    ln -sf "$rel_path" "$target_dir/$file"
    echo "  ↳ $file -> $rel_path"
  done
}

# --- Generate CLAUDE.md entry file ---
generate_claude_md() {
  local claude_md="CLAUDE.md"
  local rules_dir=".claude/rules"

  download_standards "$rules_dir"

  cat > "$claude_md" << ENTRY
# aicoding standards
# source: ${SOURCE}
# installed: ${INSTALLED_AT}
ENTRY

  cat >> "$claude_md" << 'ENTRY'

## MCP: Serena

- Always use Serena MCP tools for codebase navigation and symbol lookup before falling back to file reading.
- Run `activate_project` + `check_onboarding_performed` at the start of each session if Serena is available.
- Use Serena's semantic understanding (symbol lookup, references, type hierarchy) instead of relying solely on text search.
- If Serena is not available, fall back to standard file reading and search tools.

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Standards (auto-loaded from .claude/rules/)

The following rules are automatically loaded into your context at session start.
You do NOT need to read them manually — they are already available to you.

ENTRY

  for i in "${!FILES[@]}"; do
    for d in "${DOWNLOADED[@]}"; do
      if [ "$d" = "${FILES[$i]}" ]; then
        echo "- **${FILES[$i]%.md}**: ${DESCRIPTIONS[$i]}" >> "$claude_md"
        break
      fi
    done
  done

  cat >> "$claude_md" << 'ENTRY'

## When to Apply Which Rules

| Task | Primary Rules | Key Actions |
|------|--------------|-------------|
| **Any task** | ai-behavior | Follow 5-step flow: Research → Plan → Implement → Verify → Report |
| **Write backend code** | code-quality, architecture, lang-* | TDD flow, layered architecture, DI, typed interfaces |
| **Add new feature module** | architecture, lang-* | Create files in order: model → repo → service → handler → test |
| **Add API endpoint** | code-quality, lang-*, security | Follow API endpoint flow, validate input, check security checklist |
| **Frontend changes** | lang-frontend, harness-engineering, code-quality | Feature-based structure, component design, a11y, browser screenshot verification |
| **New project setup** | project-ops | Docker-first: Dockerfile → docker-compose.yml → Makefile → linter setup → /health |
| **Fix a bug** | code-quality, ai-behavior | Write failing test first, fix, verify, report |
| **Security review** | security | Run 10-item security checklist before completion |
| **Refactor / cleanup** | architecture, harness-engineering | Structural tests, no layer violations, strengthen harness |
| **Write tests** | code-quality | TDD steps, mock externals, descriptive names, run in Docker |
| **Docker / infra** | project-ops | Multi-stage build, non-root, healthcheck, pin versions |

## Task Execution Flow

1. Research: read related source files to understand existing patterns
2. Plan: list files to change, confirm with user if >3 files
3. Implement: one feature at a time, TDD (test first → implement → verify)
4. Verify: run tests + lint inside Docker, screenshot for frontend
5. Report: use the completion report format from ai-behavior rules
ENTRY

  echo "✓ Generated $claude_md (entry file)"
}

# --- Generate Kiro steering files ---
generate_kiro_steering() {
  local steering_dir=".kiro/steering"
  local entry_file="$steering_dir/standards.md"

  # Skip download if files were already linked (--all mode)
  if [ "${KIRO_LINKED:-}" != "true" ]; then
    download_standards "$steering_dir"
  fi

  cat > "$entry_file" << ENTRY
---
inclusion: always
---
# aicoding standards
# source: ${SOURCE}
# installed: ${INSTALLED_AT}
ENTRY

  cat >> "$entry_file" << 'ENTRY'

## MCP: Serena

- Always use Serena MCP tools for codebase navigation and symbol lookup before falling back to file reading.
- Run `activate_project` + `check_onboarding_performed` at the start of each session if Serena is available.
- Use Serena's semantic understanding (symbol lookup, references, type hierarchy) instead of relying solely on text search.
- If Serena is not available, fall back to standard file reading and search tools.

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Standards (auto-loaded from .kiro/steering/)

The following steering files are automatically loaded into your context.
You do NOT need to read them manually — they are already available to you.

ENTRY

  for i in "${!FILES[@]}"; do
    for d in "${DOWNLOADED[@]}"; do
      if [ "$d" = "${FILES[$i]}" ]; then
        echo "- **${FILES[$i]%.md}**: ${DESCRIPTIONS[$i]}" >> "$entry_file"
        break
      fi
    done
  done

  cat >> "$entry_file" << 'ENTRY'

## When to Apply Which Rules

| Task | Primary Rules | Key Actions |
|------|--------------|-------------|
| **Any task** | ai-behavior | Follow 5-step flow: Research → Plan → Implement → Verify → Report |
| **Write backend code** | code-quality, architecture, lang-* | TDD flow, layered architecture, DI, typed interfaces |
| **Add new feature module** | architecture, lang-* | Create files in order: model → repo → service → handler → test |
| **Add API endpoint** | code-quality, lang-*, security | Follow API endpoint flow, validate input, check security checklist |
| **Frontend changes** | lang-frontend, harness-engineering, code-quality | Feature-based structure, component design, a11y, browser screenshot verification |
| **New project setup** | project-ops | Docker-first: Dockerfile → docker-compose.yml → Makefile → linter setup → /health |
| **Fix a bug** | code-quality, ai-behavior | Write failing test first, fix, verify, report |
| **Security review** | security | Run 10-item security checklist before completion |
| **Refactor / cleanup** | architecture, harness-engineering | Structural tests, no layer violations, strengthen harness |
| **Write tests** | code-quality | TDD steps, mock externals, descriptive names, run in Docker |
| **Docker / infra** | project-ops | Multi-stage build, non-root, healthcheck, pin versions |

## Task Execution Flow

1. Research: read related source files to understand existing patterns
2. Plan: list files to change, confirm with user if >3 files
3. Implement: one feature at a time, TDD (test first → implement → verify)
4. Verify: run tests + lint inside Docker, screenshot for frontend
5. Report: use the completion report format from ai-behavior rules
ENTRY

  echo "✓ Generated $entry_file (entry file)"
}

# --- Main ---
echo "=== AI Development Standards ==="
echo ""

case "$TARGET" in
  claude)
    generate_claude_md
    ;;
  kiro)
    generate_kiro_steering
    ;;
  all)
    generate_claude_md
    echo ""
    # Reuse downloaded files via symlinks instead of downloading again
    link_standards ".claude/rules" ".kiro/steering"
    KIRO_LINKED=true generate_kiro_steering
    ;;
esac

# --- Generate update script ---
generate_update_script() {
  local update_file=".aicoding-update.sh"
  local args=""
  case "$TARGET" in
    kiro) args=" -s -- --kiro" ;;
    all)  args=" -s -- --all" ;;
  esac
  cat > "$update_file" << EOF
#!/usr/bin/env bash
# Auto-generated by aicoding setup.sh
# Re-run to update all AI development standards
curl -fsSL ${BASE_URL}/setup.sh | bash${args}
EOF
  chmod +x "$update_file"
  echo "✓ Generated $update_file (run this to update standards)"
}

generate_update_script

echo ""
echo "Done! Standards installed from ${SOURCE}"
echo "To update later, run: ./.aicoding-update.sh"
