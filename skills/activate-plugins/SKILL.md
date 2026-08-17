---
name: activate-plugins
description: Install and activate this user's standard Claude Code plugin set (code-review, claude-code-setup, code-simplifier, superpowers, understand-anything, claude-mem, context7) and skill suite (gstack) in the current session. Invoke when the user says "activate-plugins", "ladda mina plugins", "aktivera mina plugins", or "kör plugin-setupen".
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

### 3. Install gstack skill suite

```bash
if [ ! -f ~/.claude/skills/gstack/SKILL.md ]; then
  GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 \
    https://github.com/garrytan/gstack ~/.claude/skills/gstack
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
