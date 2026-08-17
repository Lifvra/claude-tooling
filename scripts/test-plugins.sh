#!/bin/bash
# Verifies that all expected plugins and skill suites are installed.
# Exit 0 = OK, Exit 1 = something missing.

EXPECTED_PLUGINS=(
  "code-review"
  "claude-code-setup"
  "code-simplifier"
  "superpowers"
  "understand-anything"
  "claude-mem"
  "context7"
)

EXPECTED_SKILL_DIRS=(
  "$HOME/.claude/skills/gstack"
)

MISSING=()
INSTALLED=$(claude plugin list 2>/dev/null || echo "")

for plugin in "${EXPECTED_PLUGINS[@]}"; do
  if ! echo "$INSTALLED" | grep -q "$plugin"; then
    MISSING+=("plugin:$plugin")
  fi
done

for dir in "${EXPECTED_SKILL_DIRS[@]}"; do
  skill_name=$(basename "$dir")
  if [ ! -f "$dir/SKILL.md" ]; then
    MISSING+=("skill:$skill_name")
  fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
  echo "OK: All ${#EXPECTED_PLUGINS[@]} plugins + ${#EXPECTED_SKILL_DIRS[@]} skill suite(s) present"
  exit 0
else
  echo "MISSING (${#MISSING[@]}): ${MISSING[*]}"
  exit 1
fi
