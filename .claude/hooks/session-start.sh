#!/bin/bash
set -euo pipefail

# Only run in remote Claude Code sessions (web/cloud containers).
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}"

echo "[session-start] Setting up claude-tooling..."

# Ensure scripts are executable.
chmod +x scripts/*.sh 2>/dev/null || true

# Install plugins and skill suites so they're available when working in this repo.
bash scripts/session-start-plugins.sh

echo "[session-start] Done."
