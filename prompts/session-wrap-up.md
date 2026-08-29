# Session Wrap-Up — Lifvra

Paste this at the end of every Claude Code session before closing.

```
Run this end-of-session wrap-up sequence:

## 1. Release Work Claims
Call `mcp__HQ__list_active_work_claims` — for any claim this session owns, call `mcp__HQ__release_work_claim` to free it.

## 2. Open PRs — Subscribe & Hand Off
For any PR opened this session:
- Confirm `subscribe_pr_activity` is active on it
- If session is ending and PR is not yet merged/green, post one status comment on the PR summarizing current state and what's left (CI, review, etc.)

## 3. Memory Sync (Shared Brain)
Write observations to claude-mem for anything worth remembering across sessions. Call `mcp__plugin_claude-mem_mcp-search__important_workflow` if a new pattern or decision was established. Things to capture:
- What was built / changed and in which repo
- Any architectural decisions made
- Any blockers or open questions
- Any coordination patterns that worked or caused friction
- Links to PRs opened

## 4. Update Coordination Files
If work touched shared scope (shared-memory docs, contracts, brand, skills, backend functions/migrations):
- Confirm changes are committed and pushed to the correct branch
- Note in the coordination ledger if a handoff to Sofia/Lovable is needed (e.g. backend merged → needs Lovable Publish + post-merge verification loop per `sofia-github-loop.md §10.1`)
- If a Lovable publish is required, call `mcp__Lovable__send_message` to the relevant project with a handoff note

## 5. Parallel Session Check
Call `mcp__Claude_Code_Remote__list_sessions` (mine: true) — if other sessions are still active in the same repos, note any handoff they need to know about. Use `mcp__Claude_Code_Remote__create_trigger` with `persistent_session_id` to message them if needed.

## 6. Session Summary
Output this wrap-up block:

---
### Session wrap-up — [date]

**Completed:**
- [bullet list of what was done]

**Open / in-flight:**
- [PRs still open, CI pending, deliberations awaiting human, etc.]

**Handoffs needed:**
- [Sofia/Lovable publish, parallel session coordination, human decisions, etc.]

**Remembered to shared brain:**
- [what was written to claude-mem]

**Claims released:** [N]
---
```
