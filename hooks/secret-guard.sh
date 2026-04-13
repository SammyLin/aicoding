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
# Tuned to minimize false negatives — we'd rather block a legitimate edge case
# (user can edit this file to whitelist) than leak a secret.
#
# Prefer substring matches without whitespace boundaries so that path-embedded
# references (e.g. `cat ~/.ssh/id_rsa`) are still caught.
declare -a PATTERNS=(
  # .env files — any extension or dot-suffix variant (.env, .env.local, .env-prod, .env_staging)
  # followed by non-alphanumeric so we don't catch words like ".envoy" or ".envelope"
  '\.env([^[:alnum:]]|$)'

  # Common SSH/auth key filenames — catch them anywhere (path-embedded is common)
  'id_rsa([^[:alnum:]]|$)'
  'id_ed25519([^[:alnum:]]|$)'
  'id_ecdsa([^[:alnum:]]|$)'
  '\.ssh/'

  # Inline secret material
  'AWS_SECRET_ACCESS_KEY'
  'AWS_SESSION_TOKEN'
  'PRIVATE[_-]KEY'
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'

  # Catastrophic deletes
  'rm[[:space:]]+-rf?[[:space:]]+/($|[[:space:]])'    # rm -rf / or rm -r /
  'rm[[:space:]]+-rf?[[:space:]]+~($|/)'              # rm -rf ~ or rm -rf ~/
  'rm[[:space:]]+-rf?[[:space:]]+\$HOME($|/)'         # rm -rf $HOME

  # Pipe-to-shell supply-chain patterns
  'curl[^|]*\|[[:space:]]*(sh|bash|zsh)([[:space:]]|$)'
  'wget[^|]*\|[[:space:]]*(sh|bash|zsh)([[:space:]]|$)'

  # Force-push: rewrites shared history
  'git[[:space:]]+push[[:space:]].*--force'
  'git[[:space:]]+push[[:space:]]+-f($|[[:space:]])'
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
