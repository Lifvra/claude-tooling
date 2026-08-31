# Session Start — Lifvra

Paste this at the top of every new Claude Code session.

```
/activate-plugins

Run this full startup sequence and report a compact status table at the end.
Run all independent steps in parallel.

## 1. Plugins
Run `~/.claude/session-start-plugins.sh && ~/.claude/test-plugins.sh`
Report: pass/fail + plugin count

## 2. Shared Brain (Memory)
Call `mcp__plugin_claude-mem_mcp-search__session_start_context` with:
- projects: "lifvra/hq,lifvra/web,lifvra/landing"
Report: what context was injected, or "first session / empty"

**Cloud sync** (local sessions only): check `http://127.0.0.1:${CLAUDE_MEM_WORKER_PORT:-37700}/api/sync/status`
— report configured+reachable ✅ or warn ⚠️ to run `claude-mem:cloud-sync`.
In remote sessions: N/A — git-backed backup loop handles both import (session start) and export
(session end via `mem-backup-export.sh` → `claude-mem-backup` branch). No cloud-sync required.

## 3. MCPs
Call `ListConnectors` — list each as ✅ connected+enabled, ⚠️ enabled but unknown state, ❌ disabled in chat

## 4. Skills — full inventory check
Confirm ALL of the following are present in the skill list. Missing = ❌ gap.

**Plugin suites:** superpowers, claude-mem, understand-anything, code-review, context7
**Skill suites:** gstack, task-observer
**Lifvra workflow skills:** secret-detection, deploy, preview-testing,
three-role-code-review, verify-before-claiming-done, pre-approve-architecture-check,
test-driven-development, investigate-root-cause, internal-autoplan,
independent-diff-review, lifvra-visual-review, service-index-lookup

## 5. Trio Coordination (read, don't act yet)
Run these in parallel:
- `mcp__HQ__get_coordination_ledger` — active work claims across trio; flag any WIP row older than 14 days as ⚠️ stale
- `mcp__HQ__list_active_work_claims` — intra-HQ session claims (§4.1)
- `mcp__HQ__get_urgent_triage` — anything urgent right now
- `mcp__HQ__get_ecosystem_status` — live health of HQ/Web/Landing
- `mcp__HQ__list_open_deliberations` — open Council decisions needing human
- `mcp__Claude_Code_Remote__list_sessions` (mine: true) — detect parallel sessions in the same repos; include task_summary if present

Report: summarize active claims, conflicts, stale ledger rows, urgent items,
open deliberations, and parallel sessions that could cause overlap.

## 6. Status Report
Output a single compact table:

| Check | Status | Notes |
|---|---|---|
| Plugins | ✅/❌ | N/7 plugins |
| Memory | ✅/empty | |
| Cloud sync | ✅/⚠️/N/A | configured+reachable / warning / remote session |
| MCPs | N/14 active | list any ❌ |
| Plugin suites | ✅/❌ | superpowers, claude-mem, understand-anything, code-review, context7 |
| Skill suites | ✅/❌ | gstack, task-observer |
| Lifvra skills | N/12 present | list any ❌ missing |
| Intra-HQ claims | N claims | list scope+owner if any |
| Trio ledger WIP | N rows (N stale) | flag stale rows |
| Urgent items | N items | list if any |
| Open deliberations | N open | awaiting_decision / awaiting_outcome / in_progress |
| Parallel sessions | N running | list titles + task_summary for overlap |

After the table: one-line summary of what to be aware of before starting work today.

## 7. Habit Triggers
Print this reminder table:

| Situation | Invoke |
|---|---|
| Designing new test coverage or writing tests | `test-driven-development` or `superpowers:test-driven-development` |
| PR with architectural scope (new edge, schema, contract, shared signal type) | `three-role-code-review` |
| Before merging any PR you own | `verify-before-claiming-done` |
| Before implementing a new feature or integration | `pre-approve-architecture-check` |
| Debugging a non-obvious bug | `investigate-root-cause` |
| Complex multi-step task needing a plan | `internal-autoplan` or `superpowers:writing-plans` |
| Reviewing a diff independently | `independent-diff-review` |
| UI/visual work touching Lifvra brand | `lifvra-visual-review` + `apple-design` |
| Need to find an existing service/edge/tool | `service-index-lookup` |
| Shared brain / STATUS updates | After each push, merge, or resolved decision. At session end: run `/session-wrap-up`. **Remote sessions:** observations auto-export to git on session end — no manual step needed. Never on a timer. |
```
