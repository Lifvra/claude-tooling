# Session Wrap-Up — Lifvra

Paste this at the end of every Claude Code session before closing.

```
Run this end-of-session wrap-up sequence. Run independent steps in parallel.

## 1. Release Work Claims
Call `mcp__HQ__list_active_work_claims` — for any claim this session owns,
call `mcp__HQ__release_work_claim` to free it.

## 2. Open PRs — Subscribe & Hand Off
For any PR opened this session:
- Confirm `subscribe_pr_activity` is active on it
- If session is ending and PR is not yet merged/green, post one status comment
  on the PR summarizing current state and what's left (CI, review, etc.)

## 3. Memory Sync (Shared Brain)
Call `mcp__plugin_claude-mem_mcp-search__important_workflow` for any new
pattern or decision established this session. Log to claude-mem:
- What was built / changed and in which repo (include PR links)
- Any architectural decisions made (and the alternatives considered)
- Any blockers or open questions
- Any coordination patterns that worked or caused friction
- Skills invoked and whether they helped — note any gaps

## 4. Update Coordination Ledger (COORDINATION.md)
If work touched trio-scope (shared-memory docs, contracts, brand, skills,
`shared_signals` types, or backend functions/migrations):
- Move completed WIP rows from §2 → §3 in
  `hq/public/docs/shared-memory/COORDINATION.md` (commit + push to hq)
- Add a new §2 row if a handoff is pending (e.g. Sofia needs to Publish)
- If a Lovable publish is required, call `mcp__Lovable__send_message` to
  the relevant project with a handoff note per `sofia-github-loop.md §10.1`

If work was hq-only (skills, hooks, tooling — not trio-scope), skip the
ledger edit but still release claims (step 1).

## 5. Update STATUS.md
If the session made meaningful progress on anything tracked in a repo's
STATUS.md (typically `hq/STATUS.md`):
- Add a dated entry summarizing what changed, what's in-flight, and any
  open blockers
- Keep it short: 3–5 bullets max per entry
- Commit + push to the branch the work is on (or directly to main for
  STATUS.md updates if they're trivial and standalone)

## 6. Parallel Session Check
Call `mcp__Claude_Code_Remote__list_sessions` (mine: true) — if other
sessions are still active in the same repos, note any handoff they need.
Use `mcp__Claude_Code_Remote__create_trigger` with `persistent_session_id`
to message them if needed.

## 7. Session Summary
Output this wrap-up block:

---
### Session wrap-up — [date]

**Completed:**
- [bullet list of what was done, with PR/commit links]

**Open / in-flight:**
- [PRs still open, CI pending, deliberations awaiting human, etc.]

**Handoffs needed:**
- [Sofia/Lovable publish, parallel session coordination, human decisions, etc.]

**Coordination ledger:** [updated / not needed — reason]

**STATUS.md:** [updated in repo X / not needed — reason]

**Remembered to shared brain:**
- [what was written to claude-mem]

**Claims released:** [N]
---
```
