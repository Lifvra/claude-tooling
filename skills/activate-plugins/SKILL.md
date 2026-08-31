---
name: activate-plugins
description: Install and activate this user's standard Claude Code plugin set (code-review, claude-code-setup, code-simplifier, superpowers, understand-anything, claude-mem, context7) and skill suites (gstack, task-observer) in the current session. Invoke when the user says "activate-plugins", "ladda mina plugins", "aktivera mina plugins", or "kör plugin-setupen".
---

# Activate standard plugin set

When invoked, run `~/.claude/session-start-plugins.sh` — that script is the
single source of truth for marketplace registration, plugin installation, and
the gstack skill suite. Then run `~/.claude/test-plugins.sh` and show the
result.

```bash
~/.claude/session-start-plugins.sh && ~/.claude/test-plugins.sh
```

If the scripts don't exist (fresh container before the hook has run), fall back
to the manual steps below.

---

## Manual fallback

### 1. Register marketplaces

```bash
claude plugin marketplace add anthropics/claude-plugins-official || true
claude plugin marketplace add "Egonex-AI/Understand-Anything#v2.9.0" || true
claude plugin marketplace add "thedotmack/claude-mem#v13.13.1" || true
claude plugin marketplace add upstash/context7 || true
```

(`context7` is intentionally unpinned — the latest tag `v1.0.30` lacks
`.claude-plugin/marketplace.json`, so pinning fails.)

### 2. Install plugins

```bash
claude plugin install code-review@claude-plugins-official       --scope user
claude plugin install claude-code-setup@claude-plugins-official --scope user
claude plugin install code-simplifier@claude-plugins-official   --scope user
claude plugin install superpowers@claude-plugins-official        --scope user
claude plugin install understand-anything@understand-anything   --scope user
claude plugin install claude-mem@thedotmack                     --scope user
claude plugin install context7@context7-marketplace             --scope user
```

### 3. Install skill suites

```bash
if [ ! -f ~/.claude/skills/gstack/SKILL.md ]; then
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
    https://github.com/garrytan/gstack ~/.claude/skills/gstack
fi

if [ ! -f ~/.claude/skills/task-observer/SKILL.md ]; then
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
    https://github.com/rebelytics/one-skill-to-rule-them-all ~/.claude/skills/task-observer
fi
```

### 4. Verify

```bash
claude plugin list
~/.claude/test-plugins.sh
```

---

## Source of truth

Scripts live in `Lifvra/claude-tooling` — keep them in sync when adding new
plugins. SessionStart hook in `launcher-settings.json` runs
`session-start-plugins.sh` automatically on every new session.

---

## Startup sequence (run after plugins are confirmed)

When invoked with arguments, run this full startup sequence and report a
compact status table at the end. Run independent steps in parallel.

### 1. Plugins
Run `~/.claude/session-start-plugins.sh && ~/.claude/test-plugins.sh`
Report: pass/fail + plugin count

### 2. Shared Brain (Memory)
Call `mcp__plugin_claude-mem_mcp-search__session_start_context` with:
- projects: "lifvra/hq,lifvra/web,lifvra/landing"
Report: what context was injected, or "first session / empty"

### 3. MCPs
Call `ListConnectors` — list each as ✅ connected+enabled, ⚠️ enabled but
unknown state, ❌ disabled in chat

### 4. Skills — full inventory check
Confirm ALL of the following suites/skills are present in the skill list.
Missing ones are ❌ gaps that need fixing.

**Plugin suites** (installed by session-start-plugins.sh):
`superpowers`, `claude-mem`, `understand-anything`, `code-review`, `context7`

**Skill suites** (cloned by session-start-plugins.sh):
`gstack`, `task-observer`

**Lifvra workflow skills** (mirrored from hq/.agents/skills/ via mirror-skills.mjs):
`secret-detection`, `deploy`, `preview-testing`,
`three-role-code-review`, `verify-before-claiming-done`,
`pre-approve-architecture-check`, `test-driven-development`,
`investigate-root-cause`, `internal-autoplan`,
`independent-diff-review`, `lifvra-visual-review`, `service-index-lookup`

### 5. Trio Coordination (read, don't act yet)
Run these in parallel:
- `mcp__HQ__get_coordination_ledger` — active work claims across trio; flag
  any WIP row older than 14 days as ⚠️ stale
- `mcp__HQ__list_active_work_claims` — intra-HQ session claims (§4.1)
- `mcp__HQ__get_urgent_triage` — anything urgent right now
- `mcp__HQ__get_ecosystem_status` — live health of HQ/Web/Landing
- `mcp__HQ__list_open_deliberations` — open Council decisions needing human
- `mcp__Claude_Code_Remote__list_sessions` (mine: true) — detect parallel
  sessions working in the same repos; include their task_summary if present

Report: summarize active claims, conflicts, stale ledger rows, urgent items,
open deliberations, and parallel sessions that could cause overlap. Flag
anything that needs attention before starting work.

### 6. Status Report
Output a single compact table:

| Check | Status | Notes |
|---|---|---|
| Plugins | ✅/❌ | N/7 plugins |
| Memory | ✅/empty | |
| MCPs | N/14 active | list any ❌ |
| Plugin suites | ✅/❌ | superpowers, claude-mem, understand-anything, code-review, context7 |
| Skill suites | ✅/❌ | gstack, task-observer |
| Lifvra skills | N/12 present | list any ❌ missing |
| Intra-HQ claims | N claims | list scope+owner if any |
| Trio ledger WIP | N rows (N stale) | flag stale rows |
| Urgent items | N items | list if any |
| Open deliberations | N open | awaiting_decision / awaiting_outcome / in_progress |
| Parallel sessions | N running | list titles + task_summary for overlap |

After the table: one-line summary of what to be aware of before starting
work today.

### 7. Habit Triggers (always print this reminder block)

Print this table verbatim at the end of every startup so the rules are in
context:

| Situation | Invoke |
|---|---|
| Designing new test coverage or writing tests | `test-driven-development` or `superpowers:test-driven-development` |
| PR with architectural scope (new edge, schema, contract, shared signal type) | `three-role-code-review` |
| Before merging any PR you own | `verify-before-claiming-done` |
| Before implementing a new feature or integration | `pre-approve-architecture-check` (checks trio coordination §6) |
| Debugging a non-obvious bug | `investigate-root-cause` |
| Complex multi-step task needing a plan | `internal-autoplan` or `superpowers:writing-plans` |
| Reviewing a diff independently | `independent-diff-review` |
| UI/visual work touching Lifvra brand | `lifvra-visual-review` + `apple-design` |
| Need to find an existing service/edge/tool | `service-index-lookup` |
| **Shared brain / STATUS updates** | After each push, merge, or resolved decision — not on a timer. At session end: call `/standup` to log key decisions into shared brain. Never "every Nth interaction" — use state-change triggers. |
