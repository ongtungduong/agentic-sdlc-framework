# Fix `make setup` Warnings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Eliminate three false-positive warnings in `make setup` (MemPalace MCP duplicate-add, Superpowers manual-install banner on already-installed machine, Graphify verify checking the wrong artifact) without breaking the fresh-install path.

**Architecture:** Three localized edits to a single bash script. Each fix is detect-then-act: check whether the target state already holds; only run the original logic if it doesn't. The Graphify fix is a one-line substitution in the verify section. No new helpers, no new files, no new dependencies.

**Tech Stack:** Bash 5+, `claude` CLI (`mcp list`), Linux file system checks. No test framework — verification is via captured stdout/stderr and grep.

**Spec:** [docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md](../specs/2026-04-14-fix-make-setup-warnings-design.md)

---

## File Structure

**Modified file (only):**

- [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh) — three edits inside three existing functions:
  - `install_mempalace` (lines ~347–370) — gate the `claude mcp add` block on a registration check
  - `print_superpowers_instructions` (lines ~375–386) — early-return if the plugin dir exists
  - `verify_install` (line ~417) — replace the `graphify-out/` check with a binary check

No other files in the repo are touched. Hooks merge logic, ECC cherry-pick, BMAD/OpenSpec install steps, the Makefile, and CLAUDE.md remain unchanged.

---

## Verification Helpers (used by every task)

To verify each function in isolation without re-running the entire `make setup` (which is slow and noisy), source the script with `main` stripped:

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\\\$@\"/d" scripts/setup-vsaf.sh)
<function_to_test>
'
```

This pattern is used in steps below as `RUN_FN <function_name>`.

---

## Task 1: Fix MemPalace MCP duplicate-add false warning

**Files:**

- Modify: [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh) — function `install_mempalace`, the `claude mcp add` block at lines 354–365

- [ ] **Step 1: Capture current (broken) behavior**

```bash
cd /home/duongot/Workspace/vsaf
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
install_mempalace
' 2>&1 | tee /tmp/vsaf-task1-before.log
grep "Could not auto-register MCP server" /tmp/vsaf-task1-before.log
```

Expected: the grep returns one match (the false warning is currently firing). If it returns nothing, MemPalace MCP isn't already registered on this machine and the bug doesn't reproduce — STOP and re-check `claude mcp list | grep mempalace` before proceeding.

- [ ] **Step 2: Apply the edit**

In [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh), inside `install_mempalace`, find this block:

```bash
        info "Registering MemPalace MCP server..."
        local MEMPALACE_PYTHON
        MEMPALACE_PYTHON="$(pipx environment --value PIPX_LOCAL_VENVS 2>/dev/null)/mempalace/bin/python"
        if [ -x "$MEMPALACE_PYTHON" ]; then
            claude mcp add mempalace -- "$MEMPALACE_PYTHON" -m mempalace.mcp_server 2>/dev/null \
                || warn "Could not auto-register MCP server — run manually: claude mcp add mempalace -- python -m mempalace.mcp_server"
        else
            claude mcp add mempalace -- python -m mempalace.mcp_server 2>/dev/null \
                || warn "Could not auto-register MCP server — run manually: claude mcp add mempalace -- python -m mempalace.mcp_server"
        fi
```

Replace it with:

```bash
        if claude mcp list 2>/dev/null | grep -q '^mempalace:'; then
            ok "MemPalace MCP server already registered"
        else
            info "Registering MemPalace MCP server..."
            local MEMPALACE_PYTHON
            MEMPALACE_PYTHON="$(pipx environment --value PIPX_LOCAL_VENVS 2>/dev/null)/mempalace/bin/python"
            if [ -x "$MEMPALACE_PYTHON" ]; then
                claude mcp add mempalace -- "$MEMPALACE_PYTHON" -m mempalace.mcp_server 2>/dev/null \
                    || warn "Could not auto-register MCP server — run manually: claude mcp add mempalace -- python -m mempalace.mcp_server"
            else
                claude mcp add mempalace -- python -m mempalace.mcp_server 2>/dev/null \
                    || warn "Could not auto-register MCP server — run manually: claude mcp add mempalace -- python -m mempalace.mcp_server"
            fi
        fi
```

The grep pattern `^mempalace:` matches the `claude mcp list` output format (`<name>: <command> - <status>`). If `claude` is missing or the list call fails, grep gets empty input and the `if` is false, so the original add path runs unchanged.

- [ ] **Step 3: Syntax check**

Run: `bash -n scripts/setup-vsaf.sh`
Expected: no output, exit 0.

- [ ] **Step 4: Verify new behavior**

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
install_mempalace
' 2>&1 | tee /tmp/vsaf-task1-after.log
```

Then check:

```bash
grep "MemPalace MCP server already registered" /tmp/vsaf-task1-after.log
grep "Could not auto-register MCP server" /tmp/vsaf-task1-after.log
```

Expected: first grep returns one match. Second grep returns nothing.

- [ ] **Step 5: Commit**

```bash
cd /home/duongot/Workspace/vsaf
git add scripts/setup-vsaf.sh
git commit -m "fix(setup): skip MemPalace MCP add when already registered

Detect existing 'mempalace' entry in 'claude mcp list' before
attempting the add. Eliminates the false 'Could not auto-register
MCP server' warning on machines where MemPalace is already wired up.
Fresh-install path is preserved unchanged."
```

---

## Task 2: Skip Superpowers manual-install banner when plugin is already present

**Files:**

- Modify: [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh) — function `print_superpowers_instructions`, lines 375–386

- [ ] **Step 1: Capture current (broken) behavior**

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
print_superpowers_instructions
' 2>&1 | tee /tmp/vsaf-task2-before.log
grep "Superpowers cannot be automated" /tmp/vsaf-task2-before.log
```

Expected: the grep returns one match (the warn currently fires unconditionally).

Also confirm Superpowers really is installed locally:

```bash
ls -d ~/.claude/plugins/cache/claude-plugins-official/superpowers
```

Expected: prints the directory path. If it doesn't exist, the bug doesn't reproduce on this machine — STOP.

- [ ] **Step 2: Apply the edit**

In [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh), find:

```bash
print_superpowers_instructions() {
    step "Superpowers (manual step)"
    echo ""
    echo "  Superpowers requires an interactive Claude Code session."
    echo "  Run this command inside Claude Code:"
    echo ""
    echo "    /plugin install superpowers@claude-plugins-official"
    echo ""
    echo "  Then restart Claude Code."
    echo ""
    warn "Superpowers cannot be automated — complete manually after this script"
}
```

Replace with:

```bash
print_superpowers_instructions() {
    step "Superpowers (manual step)"
    local SP_DIR="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers"
    if [ -d "$SP_DIR" ]; then
        ok "Superpowers already installed"
        return
    fi
    echo ""
    echo "  Superpowers requires an interactive Claude Code session."
    echo "  Run this command inside Claude Code:"
    echo ""
    echo "    /plugin install superpowers@claude-plugins-official"
    echo ""
    echo "  Then restart Claude Code."
    echo ""
    warn "Superpowers cannot be automated — complete manually after this script"
}
```

The detection is a plain directory existence check — no version pinning, so future Superpowers upgrades aren't blocked or mis-detected.

- [ ] **Step 3: Syntax check**

Run: `bash -n scripts/setup-vsaf.sh`
Expected: no output.

- [ ] **Step 4: Verify new behavior**

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
print_superpowers_instructions
' 2>&1 | tee /tmp/vsaf-task2-after.log
```

Then check:

```bash
grep "Superpowers already installed" /tmp/vsaf-task2-after.log
grep "Superpowers cannot be automated" /tmp/vsaf-task2-after.log
grep "/plugin install superpowers" /tmp/vsaf-task2-after.log
```

Expected: first grep returns one match. Second and third return nothing (the instruction block is also skipped, since the early `return` happens before the echos).

- [ ] **Step 5: Commit**

```bash
git add scripts/setup-vsaf.sh
git commit -m "fix(setup): skip Superpowers manual instructions when already installed

Early-return from print_superpowers_instructions when the plugin
cache dir exists at ~/.claude/plugins/cache/claude-plugins-official/superpowers.
Fresh machines still see the full manual-install block and warn."
```

---

## Task 3: Fix Graphify verify check (binary, not output dir)

**Files:**

- Modify: [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh) — function `verify_install`, line 417

- [ ] **Step 1: Capture current (broken) behavior**

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
verify_install
' 2>&1 | tee /tmp/vsaf-task3-before.log
grep "Graphify output directory exists" /tmp/vsaf-task3-before.log
```

Expected: grep returns one match, and the line ends with `— FAILED` because `graphify-out/` doesn't exist after `make setup`.

- [ ] **Step 2: Apply the edit**

In [scripts/setup-vsaf.sh](../../../scripts/setup-vsaf.sh), find:

```bash
    verify_cmd "ls graphify-out/ 2>/dev/null"       "Graphify output directory exists"
```

Replace with:

```bash
    verify_cmd "command -v graphify"                "Graphify binary available"
```

This matches the format of the surrounding `verify_cmd` calls (e.g. the MemPalace line right below it) and reflects what `install_graphify` actually produces. The output directory is created later by `make index` (which runs `/graphify .`), not by `make setup`.

- [ ] **Step 3: Syntax check**

Run: `bash -n scripts/setup-vsaf.sh`
Expected: no output.

- [ ] **Step 4: Verify new behavior**

```bash
bash -c '
set -uo pipefail
source <(sed "/^main \"\$@\"/d" scripts/setup-vsaf.sh)
verify_install
' 2>&1 | tee /tmp/vsaf-task3-after.log
```

Then check:

```bash
grep "Graphify binary available" /tmp/vsaf-task3-after.log
grep "Graphify output directory exists" /tmp/vsaf-task3-after.log
```

Expected: first grep returns one match, NOT followed by `— FAILED`. Second grep returns nothing.

Also sanity-check the count of `[OK]` lines didn't drop:

```bash
grep -c "^\\[OK\\]" /tmp/vsaf-task3-before.log
grep -c "^\\[OK\\]" /tmp/vsaf-task3-after.log
```

Expected: the "after" count is `before + 1` (the previously-failed graphify check now passes).

- [ ] **Step 5: Commit**

```bash
git add scripts/setup-vsaf.sh
git commit -m "fix(setup): verify graphify binary, not graphify-out dir

The verify step previously checked for graphify-out/, which is
produced by 'make index' (running /graphify .), not by 'make setup'.
Replace with 'command -v graphify', matching the pattern of the
surrounding verify_cmd calls."
```

---

## Task 4: End-to-end re-run and self-review

**Files:** (read-only — no modifications)

- [ ] **Step 1: Run full make setup and capture output**

```bash
cd /home/duongot/Workspace/vsaf
make setup 2>&1 | tee /tmp/vsaf-setup-final.log
```

Expected: the script completes without exit-on-error.

- [ ] **Step 2: Verify all three target lines are present**

```bash
grep "MemPalace MCP server already registered" /tmp/vsaf-setup-final.log
grep "Superpowers already installed" /tmp/vsaf-setup-final.log
grep "Graphify binary available" /tmp/vsaf-setup-final.log
```

Expected: each grep returns exactly one match.

- [ ] **Step 3: Verify all three original false warnings are gone**

```bash
grep -E "Could not auto-register MCP server|Superpowers cannot be automated|Graphify output directory exists" /tmp/vsaf-setup-final.log
```

Expected: no matches.

- [ ] **Step 4: Verify no NEW warnings were introduced**

```bash
grep "^\[WARN\]" /tmp/vsaf-setup-final.log
```

Expected output: only warnings that existed before this plan ran (e.g. unrelated install steps) — NOT any of the three we just fixed. If a new warning appears that wasn't in the original three, STOP and investigate.

- [ ] **Step 5: Verify the verify-section count improved**

```bash
grep -A 20 "Verifying installation" /tmp/vsaf-setup-final.log | grep "Verification:"
```

Expected: a line like `[INFO]  Verification: 7/7 checks passed` (or whatever the total is — must be `N/N`, not `N/M` with N<M).

- [ ] **Step 6: Confirm no untracked changes outside scripts/setup-vsaf.sh**

```bash
git status --short
```

Expected: only the four files already known to be modified before this plan started (`_bmad/_config/files-manifest.csv`, `_bmad/_config/manifest.yaml`, `_bmad/bmm/config.yaml`, `_bmad/core/config.yaml`) plus nothing new from this plan, since `scripts/setup-vsaf.sh` was already committed by the previous tasks.

If `scripts/setup-vsaf.sh` shows up as modified here, one of the previous task commits failed — STOP and investigate.

- [ ] **Step 7: Final git log check**

```bash
git log --oneline -5
```

Expected: the top three commits are the three from Tasks 1–3, in order:

```
<sha> fix(setup): verify graphify binary, not graphify-out dir
<sha> fix(setup): skip Superpowers manual instructions when already installed
<sha> fix(setup): skip MemPalace MCP add when already registered
```

No extra commits, no commits out of order.

---

## Out of Scope

- Auto-running `/graphify .` during setup (requires interactive Claude Code session)
- Auto-installing the Superpowers plugin (same constraint)
- Version pinning the Superpowers detection (would block legitimate upgrades)
- Refactoring `verify_install` to consolidate patterns
- Any change to BMAD, OpenSpec, ECC cherry-pick, GitNexus, claude-mem, hooks, or Makefile targets
- Pushing the commits to remote (separate explicit step if the user asks)
