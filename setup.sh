#!/usr/bin/env bash
set -euo pipefail

# AI Development Standards Setup
# Usage:
#   Claude Code: curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
#   Kiro:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
#   Both:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all

VERSION="v4.4"
BASE_URL="https://raw.githubusercontent.com/SammyLin/aicoding/main"
SOURCE="https://github.com/SammyLin/aicoding"

FILES=(
  "code-quality.md"
  "architecture.md"
  "security.md"
  "project-ops.md"
  "ai-behavior.md"
  "harness-engineering.md"
)

DESCRIPTIONS=(
  "Code quality, testing, error handling, typing"
  "Layered architecture, DI, module boundaries"
  "Secrets, input validation, MCP server rules"
  "Project structure, git, CI/CD, observability"
  "AI agent behavior rules and quick reference"
  "Harness engineering: docs structure, guardrails, feedback loops"
)

# --- Parse args ---
TARGET="claude"
for arg in "$@"; do
  case "$arg" in
    --kiro)  TARGET="kiro" ;;
    --all)   TARGET="all" ;;
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

# --- Generate CLAUDE.md entry file ---
generate_claude_md() {
  local claude_md="CLAUDE.md"
  local rules_dir=".claude/rules"

  download_standards "$rules_dir"

  # Don't overwrite existing CLAUDE.md, append marker if needed
  if [ -f "$claude_md" ]; then
    if grep -q "aicoding standards" "$claude_md" 2>/dev/null; then
      echo "CLAUDE.md already contains standards. Skipping entry file generation."
      return
    fi
    echo "" >> "$claude_md"
    echo "# --- aicoding standards ${VERSION} ---" >> "$claude_md"
  else
    cat > "$claude_md" << ENTRY
# aicoding standards ${VERSION}
# source: ${SOURCE}
ENTRY
  fi

  cat >> "$claude_md" << 'ENTRY'

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

  download_standards "$steering_dir"

  if [ -f "$entry_file" ]; then
    if grep -q "aicoding standards" "$entry_file" 2>/dev/null; then
      echo "standards.md already contains standards. Skipping entry file generation."
      return
    fi
    echo "" >> "$entry_file"
    echo "# --- aicoding standards ${VERSION} ---" >> "$entry_file"
  else
    cat > "$entry_file" << ENTRY
---
inclusion: always
---
# aicoding standards ${VERSION}
# source: ${SOURCE}
ENTRY
  fi

  cat >> "$entry_file" << 'ENTRY'

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
echo "=== AI Development Standards ${VERSION} ==="
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
    generate_kiro_steering
    ;;
esac

echo ""
echo "Done! Standards installed from ${SOURCE}"
