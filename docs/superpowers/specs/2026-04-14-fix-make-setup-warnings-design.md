# Fix `make setup` Warnings — Design

**Date:** 2026-04-14
**Status:** Approved (design)
**Scope:** Single file — [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh)

---

## Problem

Running `make setup` on a machine where the framework is already bootstrapped emits three warnings that look like real failures but aren't:

```
[WARN]  Could not auto-register MCP server — run manually: claude mcp add mempalace -- python -m mempalace.mcp_server
[WARN]  Superpowers cannot be automated — complete manually after this script
[WARN]  Graphify output directory exists — FAILED
```

All three are false negatives caused by setup logic that doesn't account for "already installed" or "produced later by a different command" states. They erode trust in the verification output — a real failure would be lost in the noise.

## Root Causes

### 1. MemPalace MCP false warning
[install_mempalace](../../../scripts/setup-vsaf.sh#L347-L370) calls `claude mcp add mempalace ...` unconditionally. On a machine where MemPalace is already registered (confirmed via `claude mcp list`: `mempalace: ... ✓ Connected`), the add command exits non-zero because the entry already exists. The error is swallowed by `2>/dev/null`, the `||` branch fires, and the warn is printed even though the MCP server is healthy.

### 2. Superpowers "warning" fires when already installed
[print_superpowers_instructions](../../../scripts/setup-vsaf.sh#L375-L386) prints the manual install block and a `[WARN]` line unconditionally. On this machine Superpowers `5.0.7` is already installed at `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.7`. The script has no detection — it always prints the instructions.

### 3. Graphify verify checks the wrong artifact
[verify_install](../../../scripts/setup-vsaf.sh#L417) runs:

```bash
verify_cmd "ls graphify-out/ 2>/dev/null"  "Graphify output directory exists"
```

But [install_graphify](../../../scripts/setup-vsaf.sh#L323-L332) only installs the binary and runs `graphify install` — it never produces `graphify-out/`. That directory is created later when the user runs `/graphify .` (or `make index`). The verify step is checking for an artifact setup never claims to produce, so it always fails on a fresh setup.

## Goal

Re-run `make setup` on this machine and see:

- `[OK] MemPalace MCP server already registered` (no warn)
- `[OK] Superpowers already installed` (no manual instructions block, no warn)
- `[OK] Graphify binary available` in the verify section (no warn)
- All other steps unchanged
- Fresh-machine path still works: when MemPalace MCP is *not* registered, the script still tries to add it; when Superpowers is *not* installed, the script still prints the manual instructions

## Approach

Three localized edits to [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh). No new helpers, no new files, no behavior changes outside the three warning paths.

### Change 1 — `install_mempalace`: detect existing MCP registration

Before calling `claude mcp add mempalace ...`, check whether it's already registered:

```bash
if claude mcp list 2>/dev/null | grep -q '^mempalace:'; then
    ok "MemPalace MCP server already registered"
else
    # existing add logic
fi
```

The grep anchors on `^mempalace:` to match the `claude mcp list` output format (`<name>: <command> - <status>`). If `claude` itself is missing, the grep returns nothing and we fall through to the existing add path, which already handles failure with a warn.

**Why:** Idempotent — re-runs no longer emit a false warning, and the fresh-install path is preserved exactly.

### Change 2 — `print_superpowers_instructions`: detect existing plugin install

Before printing the manual instructions, check for the plugin cache directory:

```bash
local SP_DIR="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
if [ -d "$SP_DIR" ]; then
    ok "Superpowers already installed"
    return
fi
# existing instructions block
```

Detection is by directory presence only — no version pinning, so future Superpowers upgrades aren't blocked or mis-detected.

**Why:** Option (b) from brainstorming — silent skip when installed, full instructions when not. Keeps fresh-machine UX intact.

### Change 3 — `verify_install`: check graphify binary, not output dir

Replace [scripts/setup-vsaf.sh:417](../../../scripts/setup-vsaf.sh#L417):

```bash
verify_cmd "ls graphify-out/ 2>/dev/null"  "Graphify output directory exists"
```

with:

```bash
verify_cmd "command -v graphify"  "Graphify binary available"
```

**Why:** The verify section's purpose is "did setup install what setup claims to install." `graphify-out/` is produced by `make index`, not `make setup`, so checking for it is a category error. `command -v graphify` matches the [MemPalace verify pattern one line below](../../../scripts/setup-vsaf.sh#L418) and reflects what `install_graphify` actually does.

## Verification

1. **Syntax check:**
   ```bash
   bash -n scripts/setup-vsaf.sh
   ```
   Expected: no output.

2. **Idempotent re-run on this machine:**
   ```bash
   make setup 2>&1 | tee /tmp/vsaf-setup-rerun.log
   ```
   Expected lines (greppable):
   ```bash
   grep "MemPalace MCP server already registered" /tmp/vsaf-setup-rerun.log
   grep "Superpowers already installed" /tmp/vsaf-setup-rerun.log
   grep "Graphify binary available" /tmp/vsaf-setup-rerun.log
   ```
   Each must return one match.

3. **No false warnings remain:**
   ```bash
   grep -E "Could not auto-register MCP server|Superpowers cannot be automated|Graphify output directory exists" /tmp/vsaf-setup-rerun.log
   ```
   Expected: no matches.

4. **Fresh-install path still works (smoke):** Manually verify by reading the diff that:
   - The MemPalace `else` branch still contains the original add-then-warn logic.
   - The Superpowers `if [ -d ]` is `return`-only — the instructions block below it is unchanged.
   - No other call sites of `verify_cmd` were touched.

   (A real fresh-install regression test would require a clean machine — out of scope for this fix.)

## Out of Scope

- Auto-running `/graphify .` during setup (requires interactive Claude Code session — same constraint that blocks Superpowers automation).
- Auto-installing the Superpowers plugin (the script's own comment at [scripts/setup-vsaf.sh:385](../../../scripts/setup-vsaf.sh#L385) acknowledges this can't be automated).
- Version pinning Superpowers detection (would block legitimate upgrades).
- Refactoring `verify_install` to consolidate patterns or add structured output.
- Any change to BMAD, OpenSpec, ECC cherry-pick, GitNexus, claude-mem, hooks, or Makefile targets.
- Committing the change to git (separate explicit step).
