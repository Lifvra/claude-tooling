---
name: activate-plugins
description: Install and activate this user's standard Claude Code plugin set (code-review, claude-code-setup, code-simplifier, understand-anything, claude-mem, context7) in the current session. Invoke when the user says "activate-plugins", "ladda mina plugins", "aktivera mina plugins", or "kör plugin-setupen".
---

# Activate standard plugin set

When invoked, do this in order and report the outcome:

1. Register each marketplace first (required — declaring `extraKnownMarketplaces`
   in settings.json alone does NOT register them; `claude plugin install` will
   fail with "not found in marketplace" without this step). Pins match
   `Lifvra/web:.claude/settings.json` exactly — keep them in sync if either
   changes. Safe to re-run:

   ```bash
   claude plugin marketplace add anthropics/claude-plugins-official || true
   claude plugin marketplace add "Egonex-AI/Understand-Anything#v2.9.0" || true
   claude plugin marketplace add "thedotmack/claude-mem#v13.13.1" || true
   claude plugin marketplace add upstash/context7 || true
   ```

   (`context7` is intentionally unpinned: no release tag yet includes
   `.claude-plugin/marketplace.json` — pinning to the latest tag, `v1.0.30`,
   fails with "Marketplace file not found".)

2. Install each plugin (note: the claude-mem marketplace registers under the
   name `thedotmack`, not `claude-mem`):

   ```bash
   claude plugin install code-review@claude-plugins-official --scope user
   claude plugin install claude-code-setup@claude-plugins-official --scope user
   claude plugin install code-simplifier@claude-plugins-official --scope user
   claude plugin install understand-anything@understand-anything --scope user
   claude plugin install claude-mem@thedotmack --scope user
   claude plugin install context7@context7-marketplace --scope user
   ```

3. Run `claude plugin list` and show the user the result.

4. If `/reload-plugins` is available in this environment, run it now to
   activate immediately. If it reports "isn't available in this environment"
   (expected in most cloud sessions), tell the user: installation is complete
   and persisted to disk, but this specific already-running session can't
   hot-reload its own plugin state — the plugins will show as active the
   next time a genuinely new session starts.
