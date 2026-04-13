#!/usr/bin/env bash
# PreToolUse hook: block Bash commands that expose secrets or touch sensitive files.
# Catches patterns that settings.json deny lists miss (e.g. commands that reference
# secret files inline, not just via direct Read/Write).
#
# Input: JSON on stdin with .tool_input.command
# Exit 0 = allow; Exit 2 = block and show reason to Claude
#
# This is defense in depth. settings.json deny is the primary barrier.

set -uo pipefail

INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$CMD" ] && exit 0

# Patterns to block. Each is a POSIX extended regex.
# Tuned to catch accidental exposure, not be an exhaustive DLP scanner.
declare -a PATTERNS=(
  '\.env($|[^[:alnum:]._-])'     # .env, .env.local, etc. (but not .envoy)
  '(^|[[:space:]])id_rsa($|[[:space:]])'
  '(^|[[:space:]])id_ed25519($|[[:space:]])'
  '(^|[[:space:]])\.ssh/'
  'AWS_SECRET_ACCESS_KEY'
  'PRIVATE[_-]KEY'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  'rm[[:space:]]+-rf[[:space:]]+/($|[[:space:]])'   # rm -rf /
  'rm[[:space:]]+-rf[[:space:]]+~($|/)'             # rm -rf ~
  'curl[^|]*\|[[:space:]]*(sh|bash)([[:space:]]|$)'
  'wget[^|]*\|[[:space:]]*(sh|bash)([[:space:]]|$)'
  'git[[:space:]]+push[[:space:]].*--force'
  'git[[:space:]]+push[[:space:]]+-f([[:space:]]|$)'
)

for p in "${PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "$p"; then
    cat >&2 <<EOF
BLOCKED by secret-guard hook: command matches sensitive pattern.
Pattern: $p
Command: $CMD

If this is a legitimate use case:
  1. Edit .claude/hooks/secret-guard.sh to whitelist the specific case, OR
  2. Ask the user to run this command manually outside Claude Code.
EOF
    exit 2
  fi
done

exit 0
