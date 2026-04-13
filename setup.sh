#!/usr/bin/env bash
set -euo pipefail

# AI Development Standards — Progressive Disclosure
#
# 3 layers:
#   1. Core rules (always loaded) — every task needs these
#   2. Language rules (auto-detected) — only install what the project uses
#   3. Skills (agent-invoked) — loaded when Claude decides it's relevant
#
# Usage:
#   Claude Code: curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash
#   Kiro:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --kiro
#   Both:        curl -fsSL https://raw.githubusercontent.com/SammyLin/aicoding/main/setup.sh | bash -s -- --all

BASE_URL="https://raw.githubusercontent.com/SammyLin/aicoding/main"
SOURCE="https://github.com/SammyLin/aicoding"
INSTALLED_AT="$(date +%Y-%m-%d)"

# ── Layer 1: Core rules (always loaded, no paths) ──
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
LANG_FILES=(    "lang-node.md"    "lang-python.md"  "lang-go.md"      "lang-frontend.md")
LANG_DETECT=(   "package.json"    "pyproject.toml"   "go.mod"          "__frontend__")
LANG_LABELS=(   "Node/TypeScript" "Python"           "Go"              "Frontend (React)")
LANG_DESCRIPTIONS=(
  "pnpm, ESLint, Prettier, Zod, vitest"
  "uv, ruff, FastAPI, Pydantic, pytest"
  "go mod, golangci-lint, constructor DI, table-driven tests"
  "React, component design, state management, a11y"
)

# ── Layer 3: Skills (agent decides when to load) ──
# Skills are directories with SKILL.md inside
SKILL_NAMES=(   "security-check"    "infra-ops"           "harness-review"              "browser-verify")
SKILL_SOURCES=( "security.md"       "project-ops.md"      "harness-engineering.md"      "agent-browser-skill.md")
SKILL_DESCRIPTIONS=(
  "10-item security checklist. Use before adding API endpoints, shipping code, or handling user input. Covers secrets, SQL injection, XSS, auth, HTTPS."
  "Docker, git workflow, CI/CD, observability standards. Use when setting up infrastructure, writing Dockerfiles, or configuring deployment."
  "Guardrails and feedback loops. Use when a mistake recurs, when fixing systemic issues, or when strengthening the development harness."
  "agent-browser CLI for frontend verification. Use when you need to visually verify frontend changes in a real browser."
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

# --- Download a single file ---
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

# --- Detect project languages ---
detect_languages() {
  local detected=()
  for i in "${!LANG_FILES[@]}"; do
    local marker="${LANG_DETECT[$i]}"
    local found=false

    if [ "$marker" = "__frontend__" ]; then
      # Frontend: check for .tsx files, vite/next config, or React in package.json
      if find . -name '*.tsx' -maxdepth 4 2>/dev/null | head -1 | grep -q .; then
        found=true
      elif [ -f "vite.config.ts" ] || [ -f "vite.config.js" ] || [ -f "next.config.js" ] || [ -f "next.config.ts" ]; then
        found=true
      elif [ -f "package.json" ] && grep -q '"react"' package.json 2>/dev/null; then
        found=true
      fi
    elif [ -f "$marker" ]; then
      found=true
    elif [ "$marker" = "pyproject.toml" ] && [ -f "requirements.txt" ]; then
      found=true
    fi

    if [ "$found" = true ]; then
      detected+=("$i")
    fi
  done
  echo "${detected[@]+"${detected[@]}"}"
}

# --- Wrap raw rule content into a SKILL.md with frontmatter ---
make_skill() {
  local name="$1" description="$2" source_content="$3" dest="$4"
  mkdir -p "$(dirname "$dest")"
  {
    echo "---"
    echo "name: $name"
    echo "description: \"$description\""
    echo "---"
    echo ""
    echo "$source_content"
  } > "$dest"
}

# ============================================================
# Generate for Claude Code
# ============================================================
generate_claude() {
  local rules_dir=".claude/rules"
  local skills_dir=".claude/skills"

  # Layer 1: Core rules
  echo "Layer 1 — Core rules (always loaded):"
  for file in "${CORE_FILES[@]}"; do
    download_file "$BASE_URL/$file" "$rules_dir/$file"
  done

  # Layer 2: Auto-detect languages
  echo ""
  echo "Layer 2 — Detecting project languages..."
  local detected
  local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"

  if [ ${#detected[@]} -eq 0 ]; then
    echo "  No languages detected. Installing all language rules."
    for i in "${!LANG_FILES[@]}"; do
      download_file "$BASE_URL/${LANG_FILES[$i]}" "$rules_dir/${LANG_FILES[$i]}"
    done
  else
    for i in "${detected[@]}"; do
      echo "  Detected: ${LANG_LABELS[$i]}"
      download_file "$BASE_URL/${LANG_FILES[$i]}" "$rules_dir/${LANG_FILES[$i]}"
    done
  fi

  # Layer 3: Skills (download source, wrap as SKILL.md)
  echo ""
  echo "Layer 3 — Skills (agent-invoked, on-demand):"
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

  # Generate CLAUDE.md
  echo ""
  generate_claude_md
}

generate_claude_md() {
  local claude_md="CLAUDE.md"

  cat > "$claude_md" << ENTRY
# aicoding standards
# source: ${SOURCE}
# installed: ${INSTALLED_AT}

## Core Philosophy

One feature at a time. Verify before moving on. No overengineering.

## How Rules Are Organized

**Layer 1 — Always loaded (\`.claude/rules/\`):**
ENTRY

  for i in "${!CORE_FILES[@]}"; do
    echo "- **${CORE_FILES[$i]%.md}**: ${CORE_DESCRIPTIONS[$i]}" >> "$claude_md"
  done

  # List detected language rules
  local detected
  local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"
  if [ ${#detected[@]} -gt 0 ]; then
    for i in "${detected[@]}"; do
      echo "- **${LANG_FILES[$i]%.md}**: ${LANG_DESCRIPTIONS[$i]}" >> "$claude_md"
    done
  else
    for i in "${!LANG_FILES[@]}"; do
      echo "- **${LANG_FILES[$i]%.md}**: ${LANG_DESCRIPTIONS[$i]}" >> "$claude_md"
    done
  fi

  cat >> "$claude_md" << 'ENTRY'

**Layer 2 — Skills (Claude auto-invokes when relevant):**

Skills are NOT pre-loaded. Claude sees their descriptions and decides when to read the full content.

ENTRY

  for i in "${!SKILL_NAMES[@]}"; do
    echo "- **${SKILL_NAMES[$i]}**: ${SKILL_DESCRIPTIONS[$i]}" >> "$claude_md"
  done

  cat >> "$claude_md" << 'ENTRY'

## Task Flow

1. Research → read related source files
2. Plan → list files to change, confirm if >3 files
3. Implement → one feature at a time, TDD
4. Verify → run tests + lint, screenshot for frontend
5. Report → completion report format (see ai-behavior)
ENTRY

  echo "✓ Generated $claude_md"
}

# ============================================================
# Generate for Kiro
# ============================================================
generate_kiro() {
  local steering_dir=".kiro/steering"
  local entry_file="$steering_dir/standards.md"

  if [ "${KIRO_LINKED:-}" != "true" ]; then
    echo "Core rules..."
    for file in "${CORE_FILES[@]}"; do
      download_file "$BASE_URL/$file" "$steering_dir/$file"
    done
    echo "Language rules..."
    local detected
    local _det
  _det=$(detect_languages)
  local detected=()
  [ -n "$_det" ] && read -ra detected <<< "$_det"
    if [ ${#detected[@]} -eq 0 ]; then
      for i in "${!LANG_FILES[@]}"; do
        download_file "$BASE_URL/${LANG_FILES[$i]}" "$steering_dir/${LANG_FILES[$i]}"
      done
    else
      for i in "${detected[@]}"; do
        download_file "$BASE_URL/${LANG_FILES[$i]}" "$steering_dir/${LANG_FILES[$i]}"
      done
    fi
    echo "On-demand rules..."
    for i in "${!SKILL_SOURCES[@]}"; do
      download_file "$BASE_URL/${SKILL_SOURCES[$i]}" "$steering_dir/on-demand/${SKILL_SOURCES[$i]}"
    done
  fi

  cat > "$entry_file" << ENTRY
---
inclusion: always
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
4. Verify → run tests + lint
5. Report → completion report format
ENTRY

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
    echo "Linking to Kiro..."
    local_rules=".claude/rules"
    kiro_dir=".kiro/steering"
    mkdir -p "$kiro_dir"
    for f in "$local_rules"/*.md; do
      [ -f "$f" ] && ln -sf "../../$f" "$kiro_dir/$(basename "$f")"
      echo "  ↳ $(basename "$f")"
    done
    KIRO_LINKED=true generate_kiro
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
echo "✓ Generated .aicoding-update.sh"

# Summary
echo ""
echo "Done!"
echo ""
rules_count=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
skills_count=$(ls -d .claude/skills/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')
echo "  .claude/rules/   ← ${rules_count} rules (always loaded)"
echo "  .claude/skills/  ← ${skills_count} skills (agent-invoked on demand)"
echo ""
echo "Update: ./.aicoding-update.sh"
