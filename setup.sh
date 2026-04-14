#!/usr/bin/env bash
set -euo pipefail

# AI Development Standards — Progressive Disclosure
#
# Installs opinionated team standards for AI coding agents:
#
#   Layer 1. Core rules         — always loaded (ai-behavior, code-quality, architecture)
#   Layer 2. Language rules      — path-scoped, auto-detected per project
#   Layer 3. Skills             — agent-invoked on-demand (security, ops, harness, browser)
#   Layer 4. Agent + Commands   — subagent + slash commands for Verify/Commit flow
#   Layer 5. Hooks + Settings   — auto-format, secret-guard, permissions
#
# Usage:
#   Claude Code: curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
#   Kiro CLI:    curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
#   Both:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/SammyLin/aicoding/main}"
SOURCE="${SOURCE:-https://github.com/SammyLin/aicoding}"
INSTALLED_AT="$(date +%Y-%m-%d)"

# ── Layer 1: Core rules (always loaded, no path scoping) ──
CORE_FILES=(
  "ai-behavior.md"
  "code-quality.md"
  "architecture.md"
)
CORE_DESCRIPTIONS=(
  "AI agent 5-step flow, commit frequency, completion report"
  "Code quality, TDD, error handling, typing"
  "Layered architecture, DI, module boundaries"
)

# ── Layer 2: Language rules (auto-detected per project) ──
# Kiro uses `fileMatchPattern` with `|` alternation; Claude uses `paths:` YAML array (already in source files).
LANG_FILES=(    "lang-node.md"                                                                 "lang-python.md"                                          "lang-go.md"                           "lang-frontend.md")
LANG_DETECT=(   "package.json"                                                                  "pyproject.toml"                                          "go.mod"                               "__frontend__")
LANG_LABELS=(   "Node/TypeScript"                                                               "Python"                                                   "Go"                                  "Frontend (React)")
LANG_DESCRIPTIONS=(
  "pnpm, ESLint, Prettier, Zod, vitest"
  "uv, ruff, FastAPI, Pydantic, pytest"
  "go mod, golangci-lint, constructor DI, table-driven tests"
  "React, component design, state management, a11y"
)
LANG_KIRO_PATTERN=(
  "**/*.ts|**/*.js|**/*.mjs|**/*.cjs|package.json|tsconfig.json|pnpm-lock.yaml"
  "**/*.py|pyproject.toml|requirements.txt|uv.lock"
  "**/*.go|go.mod|go.sum"
  "**/*.tsx|**/*.jsx|**/*.css|**/*.scss|vite.config.*|next.config.*"
)

# ── Layer 3: Skills (agent-invoked on demand) ──
SKILL_NAMES=(   "security-check"    "infra-ops"           "harness-review"              "browser-verify")
SKILL_SOURCES=( "security.md"       "project-ops.md"      "harness-engineering.md"      "agent-browser-skill.md")
SKILL_DESCRIPTIONS=(
  "10-item security checklist. Use before adding API endpoints, shipping code, or handling user input. Covers secrets, SQL injection, XSS, auth, HTTPS."
  "Docker, git workflow, CI/CD, observability standards. Use when setting up infrastructure, writing Dockerfiles, or configuring deployment."
  "Guardrails and feedback loops. Use when a mistake recurs, when fixing systemic issues, or when strengthening the development harness."
  "agent-browser CLI for frontend verification. Use when you need to visually verify frontend changes in a real browser."
)

# ── Layer 4: Agent + Commands (Claude Code only; Kiro gets agent only) ──
AGENT_FILES=( "agents/code-reviewer.md" )
COMMAND_FILES=( "commands/commit.md" "commands/review.md" )

# ── Layer 5: Hooks + Settings (Claude Code only) ──
HOOK_FILES=( "hooks/auto-format.sh" "hooks/secret-guard.sh" )
SETTINGS_SOURCE="settings.json"

# --- Parse args ---
TARGET="claude"
for arg in "$@"; do
  case "$arg" in
    --kiro)   TARGET="kiro" ;;
    --all)    TARGET="all" ;;
    --claude) TARGET="claude" ;;
  esac
done

# ============================================================
# Helpers
# ============================================================

# Download a single file. Returns 0 on success.
download_file() {
  local url="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"
  if curl -fsSL "$url" -o "$dest" 2>/dev/null; then
    echo "  ✓ $(basename "$dest")"
    return 0
  else
    echo "  ✗ $(basename "$dest") (not found)"
    rm -f "$dest"
    return 1
  fi
}

# Detect project languages. Echoes indices (separated by spaces) into LANG_FILES.
detect_languages() {
  local detected=()
  for i in "${!LANG_FILES[@]}"; do
    local marker="${LANG_DETECT[$i]}"
    local found=false

    if [ "$marker" = "__frontend__" ]; then
      if find . -name '*.tsx' -maxdepth 4 2>/dev/null | head -1 | grep -q .; then
        found=true
      elif [ -f "vite.config.ts" ] || [ -f "vite.config.js" ] || [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
        found=true
      elif [ -f "package.json" ] && grep -q '"react"' package.json 2>/dev/null; then
        found=true
      fi
    elif [ -f "$marker" ] || find . -maxdepth 2 -name "$marker" 2>/dev/null | head -1 | grep -q .; then
      found=true
    elif [ "$marker" = "pyproject.toml" ] && ([ -f "requirements.txt" ] || find . -maxdepth 2 -name "requirements.txt" 2>/dev/null | head -1 | grep -q .); then
      found=true
    fi

    if [ "$found" = true ]; then
      detected+=("$i")
    fi
  done
  echo "${detected[@]+"${detected[@]}"}"
}

# Wrap raw rule content as a Claude Code SKILL.md with frontmatter.
make_skill() {
  local name="$1" description="$2" source_content="$3" dest="$4"
  mkdir -p "$(dirname "$dest")"
  {
    echo "---"
    echo "name: $name"
    echo "description: \"$description\""
    echo "managed-by: aicoding"
    echo "---"
    echo ""
    echo "$source_content"
  } > "$dest"
}

# Strip leading YAML frontmatter from a file, echoing the body to stdout.
strip_frontmatter() {
  awk 'BEGIN{state=0} /^---$/{state++; next} state>=2{print} state==0{print}' "$1"
}

# Convert a lang rule source (Claude format with paths:) into Kiro steering format.
# If pattern is empty, use inclusion: always.
make_kiro_steering() {
  local src="$1" dest="$2" pattern="${3:-}"
  mkdir -p "$(dirname "$dest")"
  {
    echo "---"
    if [ -n "$pattern" ]; then
      echo "inclusion: fileMatch"
      echo "fileMatchPattern: \"$pattern\""
    else
      echo "inclusion: always"
    fi
    echo "managed-by: aicoding"
    echo "---"
    strip_frontmatter "$src"
  } > "$dest"
}

# Convert a Claude agent markdown file (with YAML frontmatter) into a Kiro CLI agent JSON.
# Kiro CLI agents: https://kiro.dev/docs/cli/custom-agents/
make_kiro_agent() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  # Extract frontmatter fields
  local name description
  name=$(awk 'BEGIN{s=0} /^---$/{s++; next} s==1 && /^name:/{sub(/^name:[[:space:]]*/, ""); print; exit}' "$src")
  description=$(awk 'BEGIN{s=0} /^---$/{s++; next} s==1 && /^description:/{sub(/^description:[[:space:]]*/, ""); print; exit}' "$src")

  # Extract body (everything after the second ---)
  local body
  body=$(strip_frontmatter "$src")

  # JSON-escape the prompt body
  local prompt_json
  prompt_json=$(printf '%s' "$body" | awk 'BEGIN{ORS=""} {
    gsub(/\\/, "\\\\")
    gsub(/"/, "\\\"")
    gsub(/\t/, "\\t")
    gsub(/\r/, "\\r")
    print $0 "\\n"
  }')

  # Description escape (it might contain quotes)
  local desc_json
  desc_json=$(printf '%s' "$description" | sed 's/\\/\\\\/g; s/"/\\"/g')

  # code-reviewer is read-only (review never edits) + limited to git-read commands.
  # Other agents added later may need broader tools — this currently assumes
  # the single agent we ship matches this profile.
  cat > "$dest" <<EOF
{
  "name": "$name",
  "description": "$desc_json",
  "tools": ["fs_read", "execute_bash"],
  "allowedTools": ["fs_read"],
  "toolsSettings": {
    "execute_bash": {
      "allowedCommands": [
        "git diff",
        "git diff --cached",
        "git diff HEAD",
        "git status",
        "git status --short",
        "git log",
        "git show"
      ]
    }
  },
  "prompt": "$prompt_json"
}
EOF
}

# Remove aicoding-managed files (preserve user-created ones).
clean_managed_claude() {
  local rules_dir=".claude/rules"
  local skills_dir=".claude/skills"
  local agents_dir=".claude/agents"
  local commands_dir=".claude/commands"
  local hooks_dir=".claude/hooks"

  # Core + lang rules
  local all_rule_files=("${CORE_FILES[@]}" "${LANG_FILES[@]}")
  for file in "${all_rule_files[@]}"; do
    rm -f "$rules_dir/$file"
  done

  # Skills (managed-by marker)
  if [ -d "$skills_dir" ]; then
    for skill_dir in "$skills_dir"/*/; do
      [ -d "$skill_dir" ] || continue
      local skill_file="$skill_dir/SKILL.md"
      if [ -f "$skill_file" ] && grep -q "managed-by: aicoding" "$skill_file" 2>/dev/null; then
        rm -rf "$skill_dir"
      fi
    done
  fi

  # Agents / commands / hooks: remove if shipped by us
  for f in "${AGENT_FILES[@]}"; do
    rm -f ".claude/$(basename "$f")"  # legacy path
    rm -f "$agents_dir/$(basename "$f")"
  done
  for f in "${COMMAND_FILES[@]}"; do
    rm -f "$commands_dir/$(basename "$f")"
  done
  for f in "${HOOK_FILES[@]}"; do
    rm -f "$hooks_dir/$(basename "$f")"
  done
}

clean_managed_kiro() {
  local steering_dir=".kiro/steering"
  local agents_dir=".kiro/agents"

  # Remove aicoding-tagged steering files
  if [ -d "$steering_dir" ]; then
    for f in "$steering_dir"/*.md "$steering_dir"/on-demand/*.md; do
      [ -f "$f" ] || continue
      if grep -q "managed-by: aicoding" "$f" 2>/dev/null; then
        rm -f "$f"
      fi
    done
  fi

  # Remove aicoding-tagged agents
  if [ -d "$agents_dir" ]; then
    for f in "$agents_dir"/*.json; do
      [ -f "$f" ] || continue
      if grep -q '"name":[[:space:]]*"code-reviewer"' "$f" 2>/dev/null; then
        rm -f "$f"
      fi
    done
  fi
}

# ============================================================
# Generate for Claude Code
# ============================================================
generate_claude() {
  local rules_dir=".claude/rules"
  local skills_dir=".claude/skills"
  local agents_dir=".claude/agents"
  local commands_dir=".claude/commands"
  local hooks_dir=".claude/hooks"

  clean_managed_claude

  # Layer 1: Core rules
  echo "Layer 1 — Core rules (always loaded):"
  for file in "${CORE_FILES[@]}"; do
    download_file "$BASE_URL/$file" "$rules_dir/$file"
  done

  # Layer 2: Language rules (source files already have paths: frontmatter)
  echo ""
  echo "Layer 2 — Language rules (path-scoped via paths: frontmatter):"
  local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"

  if [ ${#detected[@]} -eq 0 ]; then
    echo "  No languages detected — installing all."
    for i in "${!LANG_FILES[@]}"; do
      download_file "$BASE_URL/${LANG_FILES[$i]}" "$rules_dir/${LANG_FILES[$i]}"
    done
  else
    for i in "${detected[@]}"; do
      echo "  Detected: ${LANG_LABELS[$i]}"
      download_file "$BASE_URL/${LANG_FILES[$i]}" "$rules_dir/${LANG_FILES[$i]}"
    done
  fi

  # Layer 3: Skills
  echo ""
  echo "Layer 3 — Skills (agent-invoked on-demand):"
  for i in "${!SKILL_NAMES[@]}"; do
    local tmp_file
    tmp_file=$(mktemp)
    if curl -fsSL "$BASE_URL/${SKILL_SOURCES[$i]}" -o "$tmp_file" 2>/dev/null; then
      local content
      content=$(cat "$tmp_file")
      make_skill "${SKILL_NAMES[$i]}" "${SKILL_DESCRIPTIONS[$i]}" "$content" \
        "$skills_dir/${SKILL_NAMES[$i]}/SKILL.md"
      echo "  ✓ ${SKILL_NAMES[$i]}/"
    else
      echo "  ✗ ${SKILL_NAMES[$i]} (source not found)"
    fi
    rm -f "$tmp_file"
  done

  # Layer 4: Agents + Commands
  echo ""
  echo "Layer 4 — Agents + Commands (Verify / Commit flow):"
  for f in "${AGENT_FILES[@]}"; do
    download_file "$BASE_URL/$f" "$agents_dir/$(basename "$f")"
  done
  for f in "${COMMAND_FILES[@]}"; do
    download_file "$BASE_URL/$f" "$commands_dir/$(basename "$f")"
  done

  # Layer 5: Hooks + Settings
  echo ""
  echo "Layer 5 — Hooks + Settings (auto-format, secret-guard, permissions):"
  for f in "${HOOK_FILES[@]}"; do
    if download_file "$BASE_URL/$f" "$hooks_dir/$(basename "$f")"; then
      chmod +x "$hooks_dir/$(basename "$f")" 2>/dev/null || true
    fi
  done
  install_settings_json

  # CLAUDE.md — uses @import style to keep main file short
  echo ""
  generate_claude_md
}

install_settings_json() {
  local target=".claude/settings.json"
  local tmp
  tmp=$(mktemp)
  if ! curl -fsSL "$BASE_URL/$SETTINGS_SOURCE" -o "$tmp" 2>/dev/null; then
    echo "  ✗ settings.json (not found on remote)"
    rm -f "$tmp"
    return
  fi

  if [ ! -f "$target" ]; then
    # Fresh install — drop it in.
    cp "$tmp" "$target"
    echo "  ✓ settings.json (team-standard permissions + hooks wired up)"
    rm -f "$tmp"
    return
  fi

  # Existing settings.json. If identical to new, nothing to do.
  if cmp -s "$tmp" "$target"; then
    echo "  ✓ settings.json (already up to date)"
    rm -f "$tmp"
    return
  fi

  # Otherwise, install as sidecar and surface a concise diff so the user
  # knows exactly what changed without having to hunt for it.
  local sidecar=".claude/settings.aicoding.json"
  cp "$tmp" "$sidecar"
  echo "  ! .claude/settings.json differs from team standard"
  echo "    Team version installed as .claude/settings.aicoding.json"

  if command -v diff >/dev/null 2>&1; then
    # Temporarily disable pipefail: `head -N` SIGPIPEs upstream which would
    # otherwise break the pipeline under `set -eo pipefail`.
    set +o pipefail
    local summary
    summary=$(diff -u "$target" "$sidecar" 2>/dev/null \
      | grep -E '^[+-]' \
      | grep -vE '^(\+\+\+|---)' \
      | head -20)
    set -o pipefail
    if [ -n "$summary" ]; then
      echo ""
      echo "    Summary of changes (first 20 lines):"
      echo "    ─────────────────────────────────────"
      printf '%s\n' "$summary" | sed 's/^/      /'
      echo "    ─────────────────────────────────────"
      echo ""
      echo "    Full diff:  diff -u .claude/settings.json .claude/settings.aicoding.json"
      echo "    Accept:     mv .claude/settings.aicoding.json .claude/settings.json"
    fi
  else
    echo "    Compare manually: diff -u .claude/settings.json $sidecar"
  fi
  rm -f "$tmp"
}

generate_claude_md() {
  local claude_md="CLAUDE.md"
  local marker_start="<!-- aicoding:start -->"
  local marker_end="<!-- aicoding:end -->"

  # Build the aicoding section using @import style.
  # Keeps CLAUDE.md short; details live in the rule files.
  local aicoding_section
  aicoding_section="${marker_start}
# aicoding standards
# source: ${SOURCE}
# installed: ${INSTALLED_AT}

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Task Flow (5 steps)

1. **Research** — read related source files (use built-in Explore subagent for breadth)
2. **Plan** — list files to change, confirm if >3 files (use built-in Plan subagent)
3. **Implement** — one feature at a time, TDD; \`auto-format\` hook runs on every edit
4. **Verify** — run \`/review\` to invoke \`code-reviewer\` subagent against core rules
5. **Commit** — run \`/commit\` to lint + test + produce a conventional commit message

## Rules (path-scoped auto-loaded)

Core rules (always in context):
- @.claude/rules/ai-behavior.md
- @.claude/rules/code-quality.md
- @.claude/rules/architecture.md

Language rules (load only when matching files are in context):"

  local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"
  if [ ${#detected[@]} -gt 0 ]; then
    for i in "${detected[@]}"; do
      aicoding_section+=$'\n'"- @.claude/rules/${LANG_FILES[$i]}"
    done
  else
    for i in "${!LANG_FILES[@]}"; do
      aicoding_section+=$'\n'"- @.claude/rules/${LANG_FILES[$i]}"
    done
  fi

  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"## Skills (agent-invoked on demand)"
  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"Skills live in \`.claude/skills/\`. Claude loads one only when its description matches the task."
  aicoding_section+=$'\n'
  for i in "${!SKILL_NAMES[@]}"; do
    aicoding_section+=$'\n'"- **${SKILL_NAMES[$i]}**: ${SKILL_DESCRIPTIONS[$i]}"
  done

  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"## Subagent + Commands"
  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"- Subagent **code-reviewer** — structured review against core rules (no edits)"
  aicoding_section+=$'\n'"- Command **/review** — invokes code-reviewer on current diff"
  aicoding_section+=$'\n'"- Command **/commit** — lint + test + conventional commit message"
  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"## Hooks (automatic)"
  aicoding_section+=$'\n'
  aicoding_section+=$'\n'"- **PostToolUse** (Edit/Write/MultiEdit) → \`.claude/hooks/auto-format.sh\` (gofmt / ruff / prettier)"
  aicoding_section+=$'\n'"- **PreToolUse** (Bash) → \`.claude/hooks/secret-guard.sh\` (blocks \`.env\`, \`rm -rf\`, \`curl|sh\`)"
  aicoding_section+=$'\n'"${marker_end}"

  if [ -f "$claude_md" ] && grep -q "$marker_start" "$claude_md"; then
    local before_file after_file new_file
    before_file=$(mktemp); after_file=$(mktemp); new_file=$(mktemp)
    local in_section=false after_section=false
    while IFS= read -r line; do
      if [ "$line" = "$marker_start" ]; then in_section=true; continue; fi
      if [ "$line" = "$marker_end" ]; then in_section=false; after_section=true; continue; fi
      if [ "$after_section" = true ]; then echo "$line" >> "$after_file"
      elif [ "$in_section" = false ]; then echo "$line" >> "$before_file"
      fi
    done < "$claude_md"
    {
      [ -s "$before_file" ] && cat "$before_file"
      echo "$aicoding_section"
      [ -s "$after_file" ] && cat "$after_file"
    } > "$new_file"
    mv "$new_file" "$claude_md"
    rm -f "$before_file" "$after_file"
    echo "✓ Updated aicoding section in $claude_md (preserved project-specific content)"
  elif [ -f "$claude_md" ]; then
    local tmp_file
    tmp_file=$(mktemp)
    echo "$aicoding_section" > "$tmp_file"
    echo "" >> "$tmp_file"
    cat "$claude_md" >> "$tmp_file"
    mv "$tmp_file" "$claude_md"
    echo "✓ Prepended aicoding section to existing $claude_md"
  else
    echo "$aicoding_section" > "$claude_md"
    echo "✓ Generated $claude_md"
  fi
}

# ============================================================
# Generate for Kiro CLI
# ============================================================
generate_kiro() {
  local steering_dir=".kiro/steering"
  local agents_dir=".kiro/agents"
  local entry_file="$steering_dir/standards.md"

  clean_managed_kiro

  # Steering: core rules (always load)
  echo "Layer 1 — Core rules (always loaded):"
  for file in "${CORE_FILES[@]}"; do
    local tmp
    tmp=$(mktemp)
    if curl -fsSL "$BASE_URL/$file" -o "$tmp" 2>/dev/null; then
      make_kiro_steering "$tmp" "$steering_dir/$file" ""
      echo "  ✓ $file"
    else
      echo "  ✗ $file (not found)"
    fi
    rm -f "$tmp"
  done

  # Steering: lang rules (inclusion: fileMatch with pattern)
  echo ""
  echo "Layer 2 — Language rules (inclusion: fileMatch):"
  local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"

  local lang_indices=()
  if [ ${#detected[@]} -eq 0 ]; then
    echo "  No languages detected — installing all."
    for i in "${!LANG_FILES[@]}"; do lang_indices+=("$i"); done
  else
    lang_indices=("${detected[@]}")
  fi

  for i in "${lang_indices[@]}"; do
    local tmp
    tmp=$(mktemp)
    if curl -fsSL "$BASE_URL/${LANG_FILES[$i]}" -o "$tmp" 2>/dev/null; then
      make_kiro_steering "$tmp" "$steering_dir/${LANG_FILES[$i]}" "${LANG_KIRO_PATTERN[$i]}"
      echo "  ✓ ${LANG_FILES[$i]} → ${LANG_KIRO_PATTERN[$i]}"
    else
      echo "  ✗ ${LANG_FILES[$i]} (not found)"
    fi
    rm -f "$tmp"
  done

  # Steering: skills as on-demand (manual inclusion — user invokes by @-mention or fileMatch)
  echo ""
  echo "Layer 3 — Skills (on-demand steering):"
  mkdir -p "$steering_dir/on-demand"
  for i in "${!SKILL_SOURCES[@]}"; do
    local tmp
    tmp=$(mktemp)
    if curl -fsSL "$BASE_URL/${SKILL_SOURCES[$i]}" -o "$tmp" 2>/dev/null; then
      {
        echo "---"
        echo "inclusion: manual"
        echo "managed-by: aicoding"
        echo "---"
        cat "$tmp"
      } > "$steering_dir/on-demand/${SKILL_SOURCES[$i]}"
      echo "  ✓ on-demand/${SKILL_SOURCES[$i]}"
    fi
    rm -f "$tmp"
  done

  # Agent: code-reviewer (converted to Kiro JSON)
  echo ""
  echo "Layer 4 — Agents (code-reviewer as JSON):"
  local tmp
  tmp=$(mktemp)
  if curl -fsSL "$BASE_URL/${AGENT_FILES[0]}" -o "$tmp" 2>/dev/null; then
    make_kiro_agent "$tmp" "$agents_dir/code-reviewer.json"
    echo "  ✓ code-reviewer.json"
  else
    echo "  ✗ ${AGENT_FILES[0]} (not found)"
  fi
  rm -f "$tmp"

  # Entry file — points Kiro at everything
  cat > "$entry_file" << ENTRY
---
inclusion: always
managed-by: aicoding
---
# aicoding standards
# source: ${SOURCE}
# installed: ${INSTALLED_AT}

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## Task Flow

1. Research → read related source files
2. Plan → list files to change, confirm if >3 files
3. Implement → one feature at a time, TDD
4. Verify → invoke code-reviewer agent: \`kiro-cli chat --agent code-reviewer\`
5. Commit → conventional message, after lint + test pass

## Not installed for Kiro CLI

The following Claude Code features have no direct Kiro CLI equivalent and are skipped:

- Slash commands (\`/commit\`, \`/review\`) — Kiro CLI doesn't support user-defined slash commands
- Hooks — Kiro CLI's hook model differs (agentSpawn, userPromptSubmit, preToolUse). Configure in Kiro settings if needed.
- settings.json — Kiro CLI permissions live in Kiro's own config, not in project files

The rules and subagent above cover the core value. For hooks, see docs/hooks-cookbook.md upstream.
ENTRY

  echo ""
  echo "✓ Generated $entry_file"
}

# ============================================================
# Main
# ============================================================
echo "=== AI Development Standards ==="
echo ""

case "$TARGET" in
  claude)
    generate_claude
    ;;
  kiro)
    generate_kiro
    ;;
  all)
    generate_claude
    echo ""
    echo "=== Installing for Kiro CLI (in addition to Claude Code) ==="
    echo ""
    generate_kiro
    ;;
esac

# Generate update script
args=""
case "$TARGET" in
  kiro) args=" -s -- --kiro" ;;
  all)  args=" -s -- --all" ;;
esac
cat > ".aicoding-update.sh" << EOF
#!/usr/bin/env bash
curl -fsSL ${BASE_URL}/setup.sh | bash${args}
EOF
chmod +x ".aicoding-update.sh"
echo ""
echo "✓ Generated .aicoding-update.sh"

# Summary
echo ""
echo "Done!"
echo ""
if [ "$TARGET" = "claude" ] || [ "$TARGET" = "all" ]; then
  rules_count=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
  skills_count=$(ls -d .claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
  agents_count=$(ls .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
  commands_count=$(ls .claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ')
  hooks_count=$(ls .claude/hooks/*.sh 2>/dev/null | wc -l | tr -d ' ')
  echo "Claude Code:"
  echo "  .claude/rules/      ← ${rules_count} rules"
  echo "  .claude/skills/     ← ${skills_count} skills"
  echo "  .claude/agents/     ← ${agents_count} agent(s)"
  echo "  .claude/commands/   ← ${commands_count} command(s)"
  echo "  .claude/hooks/      ← ${hooks_count} hook(s)"
  [ -f .claude/settings.json ] && echo "  .claude/settings.json ← installed"
fi
if [ "$TARGET" = "kiro" ] || [ "$TARGET" = "all" ]; then
  kiro_steering=$(ls .kiro/steering/*.md 2>/dev/null | wc -l | tr -d ' ')
  kiro_ondemand=$(ls .kiro/steering/on-demand/*.md 2>/dev/null | wc -l | tr -d ' ')
  kiro_agents=$(ls .kiro/agents/*.json 2>/dev/null | wc -l | tr -d ' ')
  echo "Kiro CLI:"
  echo "  .kiro/steering/     ← ${kiro_steering} rules"
  echo "  .kiro/steering/on-demand/ ← ${kiro_ondemand} on-demand"
  echo "  .kiro/agents/       ← ${kiro_agents} agent(s)"
fi
echo ""
echo "Update: ./.aicoding-update.sh"
