#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Claude edits them.
# Fails silently (warning only, never blocks). Keeps Claude's flow smooth.
#
# Input: JSON on stdin with .tool_input.file_path
# Output: Silent on success; warnings to stderr on format errors
# Exit: always 0 (advisory, never blocks)

set -uo pipefail

# Read Claude Code hook payload from stdin
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Skip if no file path or file doesn't exist
[ -z "$FILE" ] && exit 0
[ ! -f "$FILE" ] && exit 0

# Dispatch by extension. Only format if the formatter is installed.
case "$FILE" in
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" 2>/dev/null || true
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$FILE" 2>/dev/null || true
    elif command -v black >/dev/null 2>&1; then
      black -q "$FILE" 2>/dev/null || true
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.json|*.md|*.css|*.scss|*.yaml|*.yml)
    if command -v prettier >/dev/null 2>&1; then
      prettier --write "$FILE" --log-level silent 2>/dev/null || true
    elif command -v npx >/dev/null 2>&1; then
      npx --no-install prettier --write "$FILE" --log-level silent 2>/dev/null || true
    fi
    ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" 2>/dev/null || true
    ;;
esac

exit 0
