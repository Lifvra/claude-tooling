# Session Start — Lifvra

Paste this at the top of every new Claude Code session.

```
/activate-plugins

Run this full startup sequence and report a compact status table at the end:

## 1. Plugins
Run `~/.claude/session-start-plugins.sh && ~/.claude/test-plugins.sh`
Report: pass/fail + plugin count

## 2. Shared Brain (Memory)
Call `mcp__plugin_claude-mem_mcp-search__session_start_context` with:
- projects: "lifvra/hq,lifvra/web,lifvra/landing"
Report: what context was injected, or "first session / empty"

## 3. MCPs
Call `ListConnectors` — list each as ✅ connected+enabled, ⚠️ enabled but unknown state, ❌ disabled in chat

## 4. Skills
Confirm these suites are present in the skill list:
superpowers, claude-mem, understand-anything, code-review, secret-detection, deploy, preview-testing

## 5. Trio Coordination (read, don't act yet)
Run these in parallel:
- `mcp__HQ__get_coordination_ledger` — active work claims across trio
- `mcp__HQ__get_urgent_triage` — anything urgent right now
- `mcp__HQ__get_ecosystem_status` — live health of HQ/Web/Landing
- `mcp__HQ__list_open_deliberations` — open Council decisions needing human
- `mcp__Claude_Code_Remote__list_sessions` (mine: true) — detect any parallel sessions working in the same repos

Report: summarize any active claims, conflicts, urgent items, open deliberations, or parallel sessions that could cause overlap. Flag anything that needs attention before starting work.

## 6. Status Report
Output a single compact table:

| Check | Status | Notes |
|---|---|---|
| Plugins | ✅/❌ | |
| Memory | ✅/empty | |
| MCPs | N/14 active | list any ❌ |
| Skills | ✅/❌ | |
| Active work claims | N claims | list if any |
| Urgent items | N items | list if any |
| Open deliberations | N open | list if any |
| Parallel sessions | N sessions | list if any overlap |

After the table: one-line summary of what to be aware of before starting work today.
```
