#!/bin/bash
# Idempotent: register marketplaces + install plugins + install skill suites.
# Runs at every SessionStart — safe to re-run.

LOG_PREFIX="[plugins]"

log() { echo "$LOG_PREFIX $*"; }

# ── MARKETPLACES ──────────────────────────────────────────────────────────────
log "Registering marketplaces..."
claude plugin marketplace add anthropics/claude-plugins-official          2>/dev/null || true
claude plugin marketplace add "Egonex-AI/Understand-Anything#v2.9.0"      2>/dev/null || true
claude plugin marketplace add "thedotmack/claude-mem#v13.13.1"             2>/dev/null || true
claude plugin marketplace add upstash/context7                             2>/dev/null || true

# ── PLUGINS ───────────────────────────────────────────────────────────────────
log "Installing plugins..."
claude plugin install code-review@claude-plugins-official       --scope user 2>/dev/null || true
claude plugin install claude-code-setup@claude-plugins-official --scope user 2>/dev/null || true
claude plugin install code-simplifier@claude-plugins-official   --scope user 2>/dev/null || true
claude plugin install superpowers@claude-plugins-official        --scope user 2>/dev/null || true
claude plugin install understand-anything@understand-anything   --scope user 2>/dev/null || true
claude plugin install claude-mem@thedotmack                     --scope user 2>/dev/null || true
claude plugin install context7@context7-marketplace             --scope user 2>/dev/null || true

# ── SKILL SUITES (git-cloned, not marketplace plugins) ────────────────────────
GSTACK_DIR="$HOME/.claude/skills/gstack"
if [ ! -f "$GSTACK_DIR/SKILL.md" ]; then
  log "Installing gstack skill suite..."
  rm -rf "${GSTACK_DIR}.tmp"
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
    https://github.com/garrytan/gstack "${GSTACK_DIR}.tmp" 2>/dev/null \
    && mv "${GSTACK_DIR}.tmp" "$GSTACK_DIR" \
    && log "gstack installed" \
    || log "WARNING: gstack clone failed"
else
  log "gstack already present ($(cat "$GSTACK_DIR/VERSION" 2>/dev/null || echo 'version unknown'))"
fi

TASK_OBSERVER_DIR="$HOME/.claude/skills/task-observer"
if [ ! -f "$TASK_OBSERVER_DIR/SKILL.md" ]; then
  log "Installing task-observer skill..."
  rm -rf "${TASK_OBSERVER_DIR}.tmp"
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
    https://github.com/rebelytics/one-skill-to-rule-them-all "${TASK_OBSERVER_DIR}.tmp" 2>/dev/null \
    && mv "${TASK_OBSERVER_DIR}.tmp" "$TASK_OBSERVER_DIR" \
    && log "task-observer installed" \
    || log "WARNING: task-observer clone failed"
else
  log "task-observer already present"
fi

# ── VERIFY ────────────────────────────────────────────────────────────────────
log "Running verification..."
"$(dirname "$0")/test-plugins.sh" && log "All checks passed." || log "WARNING: Some checks failed — see above."

# ── MEMORY RESTORE ────────────────────────────────────────────────────────────
# Restore claude-mem observations from the git-backed backup branch.
# Runs in background so it doesn't delay session startup.
MEM_IMPORT="/home/user/web/scripts/mem-backup-import.sh"
if [ -f "$MEM_IMPORT" ]; then
  log "Starting memory restore in background..."
  bash "$MEM_IMPORT" &
fi

# ── CLOUD SYNC CHECK ──────────────────────────────────────────────────────────
# Worker is a local process — skip in remote/cloud sessions where it won't run.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  PORT="${CLAUDE_MEM_WORKER_PORT:-37700}"
  SYNC_STATUS=$(curl -s --connect-timeout 2 "http://127.0.0.1:${PORT}/api/sync/status" 2>/dev/null)
  if echo "$SYNC_STATUS" | grep -q '"configured":true'; then
    log "cloud-sync: configured"
  else
    log "WARNING: cloud-sync not configured or worker not running — run claude-mem:cloud-sync to set up"
  fi
else
  log "cloud-sync: skipped (remote session — git-backed restore is the fallback)"
fi

exit 0
