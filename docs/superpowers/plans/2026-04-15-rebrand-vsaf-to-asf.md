# Rebrand VSAF → ASF Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace every occurrence of the `VSAF`/`vsaf` brand (and the `v3` version suffix) with `ASF`/`asf` across the repo, rename the setup script, delete 4 historical spec/plan artifacts, and clean-reindex GitNexus under the new name.

**Architecture:** Single atomic commit at the end. All text replacements are driven by one Python script with an ordered list of (old, new) pairs — order matters so that longer, more-specific strings match before shorter ones (e.g. `VSAF v3 — Agentic AI SDLC Framework` must be replaced before bare `VSAF`). The script runs over an explicit file allowlist — no recursive walk, no glob, no risk of touching `.git/` or other protected directories. After content rewrite, one `git mv` renames the setup script, `git rm` removes historical artifacts, `npx gitnexus analyze` clean-builds the graph under the new repo directory name, and a final `make setup` sanity run confirms the renamed script still works end-to-end.

**Tech Stack:** bash, Python 3 (stdlib only), git, GNU grep, npx/gitnexus, make.

**Spec:** [docs/superpowers/specs/2026-04-15-rebrand-vsaf-to-asf-design.md](../specs/2026-04-15-rebrand-vsaf-to-asf-design.md)

---

## Task 1: Preflight baseline snapshot

**Files:**
- Create: `/tmp/asf-rebrand-before.txt` (ephemeral, not committed)

**Purpose:** Capture the current state of all `vsaf`/`VSAF`/`Vsaf` references so Task 7 can verify the delta is zero.

- [ ] **Step 1: Confirm working tree is clean**

Run:
```bash
git status --short
```
Expected: empty output. If there are unrelated modifications, STOP and ask the user before continuing — the atomic commit strategy assumes a clean baseline.

- [ ] **Step 2: Confirm the design spec exists**

Run:
```bash
test -f docs/superpowers/specs/2026-04-15-rebrand-vsaf-to-asf-design.md && echo OK
```
Expected: `OK`.

- [ ] **Step 3: Capture baseline grep**

Run:
```bash
grep -rInI 'vsaf\|VSAF\|Vsaf' . \
  --exclude-dir=.git --exclude-dir=.gitnexus --exclude-dir=node_modules \
  > /tmp/asf-rebrand-before.txt
wc -l /tmp/asf-rebrand-before.txt
```
Expected: ~148 lines across 18 files (matches the scope inventory in the spec). If count is wildly different (e.g. < 100 or > 200), STOP and investigate — scope has drifted since the spec was written.

- [ ] **Step 4: Confirm no `.gitnexus/` index exists**

Run:
```bash
test -e .gitnexus/meta.json && echo "EXISTS — check embeddings before re-index" || echo "CLEAN — no prior index"
```
Expected: `CLEAN — no prior index`. If `EXISTS`, STOP: read `.gitnexus/meta.json` and verify `stats.embeddings == 0` before proceeding. If embeddings > 0, user must confirm loss or the plan must switch to `--embeddings` mode.

---

## Task 2: Apply text replacements to 14 files

**Files:**
- Create: `/tmp/asf-rebrand-apply.py` (ephemeral helper script, not committed)
- Modify: all 14 files listed in the script below

**Purpose:** Replace `VSAF`/`vsaf` with `ASF`/`asf` across the non-historical content. Uses a Python script because it handles UTF-8 em-dashes, parenthesized expansions, and multiple-ordered-pair replacements more reliably than a sed pipeline.

- [ ] **Step 1: Write the rebrand script**

Create file `/tmp/asf-rebrand-apply.py`:

```python
#!/usr/bin/env python3
"""One-shot rebrand: VSAF/vsaf -> ASF/asf across an explicit file allowlist.
Order matters: longer, more-specific patterns replace before shorter ones.
"""
import pathlib
import sys

REPLACEMENTS = [
    # Longest / most-specific first
    ("VSAF v3 — Agentic AI SDLC Framework", "ASF — Agentic SDLC Framework"),
    ("VSAF v3 (Agentic AI SDLC Framework)", "ASF (Agentic SDLC Framework)"),
    ("VSAF (Version-controlled Spec-driven Agentic Framework)", "ASF (Agentic SDLC Framework)"),
    ("VSAF — SDLC Agentic Framework", "ASF — Agentic SDLC Framework"),
    ("VSAF - SDLC Agentic Framework", "ASF — Agentic SDLC Framework"),
    ("VSAF v3", "ASF"),
    # cd-command pattern must run before blanket vsaf->asf
    # (otherwise `cd vsaf` becomes `cd asf` which is a nonexistent dir)
    ("cd vsaf", "cd agentic-sdlc-framework"),
    # Blanket brand replacements
    ("VSAF", "ASF"),
    ("Vsaf", "Asf"),
    ("vsaf", "asf"),
]

FILES = [
    "CLAUDE.md",
    "AGENTS.md",
    "README.md",
    "Makefile",
    ".gitignore",
    "mempalace.yaml",
    "_bmad/bmm/config.yaml",
    "scripts/setup-vsaf.sh",
    "docs/onboarding/1-setup-guide.md",
    "docs/onboarding/2-workflow-guide.md",
    "docs/onboarding/2-workflow-guide.vi.md",
    "docs/onboarding/3-cheatsheet.md",
    "docs/onboarding/4-milestones.md",
    "docs/onboarding/5-faq.md",
]

def main() -> int:
    root = pathlib.Path.cwd()
    total = 0
    for rel in FILES:
        path = root / rel
        if not path.exists():
            print(f"MISSING: {rel}", file=sys.stderr)
            return 1
        original = path.read_text(encoding="utf-8")
        updated = original
        for old, new in REPLACEMENTS:
            updated = updated.replace(old, new)
        if updated != original:
            path.write_text(updated, encoding="utf-8")
            delta = sum(
                1 for a, b in zip(original.splitlines(), updated.splitlines()) if a != b
            ) + abs(len(original.splitlines()) - len(updated.splitlines()))
            print(f"  rewrote {rel} ({delta} lines changed)")
            total += 1
        else:
            print(f"  unchanged {rel}")
    print(f"Done: {total}/{len(FILES)} files modified")
    return 0

if __name__ == "__main__":
    sys.exit(main())
```

Write this file with the Write tool.

- [ ] **Step 2: Run the script**

Run:
```bash
python3 /tmp/asf-rebrand-apply.py
```
Expected: stdout lists each file with `rewrote` or `unchanged`, ending with `Done: N/14 files modified`. `.gitignore` may be `unchanged` except for the header comment — it should still show `rewrote` because the line `# VSAF v3 — Generated artifacts and dependencies` contains `VSAF v3`. All other 13 files must show `rewrote`. If any file shows `MISSING` the script exits 1 — STOP.

- [ ] **Step 3: Spot-check three files**

Run:
```bash
head -1 CLAUDE.md
head -1 README.md
head -1 Makefile
grep -n '^project_name' _bmad/bmm/config.yaml
grep -n '^wing' mempalace.yaml
```
Expected:
```
# ASF — Agentic SDLC Framework
# ASF — Agentic SDLC Framework
# ASF — Agentic SDLC Framework
6:project_name: asf
1:wing: asf
```

- [ ] **Step 4: Verify content-rewrite did not miss anything in the 14 files**

Run:
```bash
grep -HnI 'vsaf\|VSAF\|Vsaf' \
  CLAUDE.md AGENTS.md README.md Makefile .gitignore \
  mempalace.yaml _bmad/bmm/config.yaml \
  scripts/setup-vsaf.sh \
  docs/onboarding/1-setup-guide.md \
  docs/onboarding/2-workflow-guide.md \
  docs/onboarding/2-workflow-guide.vi.md \
  docs/onboarding/3-cheatsheet.md \
  docs/onboarding/4-milestones.md \
  docs/onboarding/5-faq.md
```
Expected: empty output. The only still-unchanged `vsaf` reference in the repo at this point should be the filename `scripts/setup-vsaf.sh` itself (Task 3 renames it) and the 4 historical artifact files under `docs/superpowers/` (Task 4 deletes them).

If any hit appears here, STOP. Either add a new replacement pair to `/tmp/asf-rebrand-apply.py` and re-run, or decide case-by-case whether the hit is intentional.

---

## Task 3: Rename the setup script

**Files:**
- Rename: `scripts/setup-vsaf.sh` → `scripts/setup-asf.sh`

- [ ] **Step 1: git mv**

Run:
```bash
git mv scripts/setup-vsaf.sh scripts/setup-asf.sh
```
Expected: no output. `git status --short` should show `R  scripts/setup-vsaf.sh -> scripts/setup-asf.sh`.

- [ ] **Step 2: Verify executable bit survived**

Run:
```bash
test -x scripts/setup-asf.sh && echo OK
```
Expected: `OK`. If not, run `chmod +x scripts/setup-asf.sh`.

- [ ] **Step 3: Confirm Makefile already points to the new name**

Run:
```bash
grep -n 'setup-.*\.sh' Makefile
```
Expected:
```
16:	@bash scripts/setup-asf.sh
```
(The rewrite in Task 2 already converted `setup-vsaf.sh` → `setup-asf.sh` inside Makefile via the blanket `vsaf` → `asf` rule.) If it still says `setup-vsaf.sh`, STOP — Task 2 did not apply cleanly to Makefile.

---

## Task 4: Delete 4 historical spec/plan artifacts

**Files:**
- Delete: `docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md`
- Delete: `docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md`
- Delete: `docs/superpowers/plans/2026-04-14-claude-settings-hardening.md`
- Delete: `docs/superpowers/plans/2026-04-14-fix-make-setup-warnings.md`

- [ ] **Step 1: Remove the four files**

Run:
```bash
git rm \
  docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md \
  docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md \
  docs/superpowers/plans/2026-04-14-claude-settings-hardening.md \
  docs/superpowers/plans/2026-04-14-fix-make-setup-warnings.md
```
Expected:
```
rm 'docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md'
rm 'docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md'
rm 'docs/superpowers/plans/2026-04-14-claude-settings-hardening.md'
rm 'docs/superpowers/plans/2026-04-14-fix-make-setup-warnings.md'
```

- [ ] **Step 2: Confirm the current rebrand spec is still there**

Run:
```bash
test -f docs/superpowers/specs/2026-04-15-rebrand-vsaf-to-asf-design.md && echo OK
test -f docs/superpowers/plans/2026-04-15-rebrand-vsaf-to-asf.md && echo OK
```
Expected: `OK` twice. These are the NEW docs for this rebrand — they must not be deleted.

---

## Task 5: Verification gates 1–3

**Files:** (none modified — read-only verification)

- [ ] **Step 1: Gate 1 — zero textual references to the old brand**

Run:
```bash
grep -rInI 'vsaf\|VSAF\|Vsaf' . \
  --exclude-dir=.git --exclude-dir=.gitnexus --exclude-dir=node_modules \
  && echo "FAIL: matches found above" || echo "OK: no matches"
```
Expected: `OK: no matches`.

If Gate 1 fails: inspect each match, add missing replacement pairs to `/tmp/asf-rebrand-apply.py` OR edit the offending file by hand, then re-run Gate 1. Do NOT proceed until green.

- [ ] **Step 2: Gate 2 — script renamed, old path gone**

Run:
```bash
test -f scripts/setup-asf.sh \
  && test ! -f scripts/setup-vsaf.sh \
  && echo OK || echo FAIL
```
Expected: `OK`.

- [ ] **Step 3: Gate 3 — historical artifacts deleted**

Run:
```bash
for f in \
  docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md \
  docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md \
  docs/superpowers/plans/2026-04-14-claude-settings-hardening.md \
  docs/superpowers/plans/2026-04-14-fix-make-setup-warnings.md; do
  test ! -e "$f" || { echo "FAIL: $f still exists"; exit 1; }
done && echo "OK: all 4 deleted"
```
Expected: `OK: all 4 deleted`.

- [ ] **Step 4: Review the full staged diff before touching GitNexus**

Run:
```bash
git status --short
git diff --cached --stat
```
Expected: status shows the staged rename (`R scripts/setup-vsaf.sh -> scripts/setup-asf.sh`) and the 4 deletions; the 13 modified files show as unstaged (`M`) because the Python script wrote them directly. Diff-stat should list roughly 18 files with the bulk of line changes concentrated in `CLAUDE.md`, `AGENTS.md`, and the onboarding guides.

If the stat shows unexpected files (e.g. something under `.claude/` or `githooks/`), STOP — Task 2's file allowlist should not have reached there. Investigate before continuing.

---

## Task 6: GitNexus clean re-index (Gate 4)

**Files:**
- Create: `.gitnexus/` (new directory, populated by `gitnexus analyze`)

- [ ] **Step 1: Run gitnexus analyze**

Run:
```bash
npx gitnexus analyze
```
Expected: gitnexus prints analyze progress, ending with an "indexed N symbols" style summary. No errors. If this fails with "command not found", run `npm install -g gitnexus` or use the project-local install path.

- [ ] **Step 2: Gate 4 — confirm the index records the new repo name**

Run:
```bash
grep -q '"asf"\|"agentic-sdlc-framework"' .gitnexus/meta.json && echo OK || { echo FAIL; cat .gitnexus/meta.json; }
```
Expected: `OK`. The exact key GitNexus uses for repo name may be `asf` (from the directory) or `agentic-sdlc-framework` depending on detection logic — either is acceptable; what matters is the absence of the literal string `vsaf`.

- [ ] **Step 3: Confirm no `vsaf` literal inside the new index**

Run:
```bash
grep -l 'vsaf' .gitnexus/ -r 2>/dev/null && echo "FAIL: vsaf literal in new index" || echo "OK: clean"
```
Expected: `OK: clean`.

---

## Task 7: Sanity-run `make setup` (Gate 5)

**Files:** (none modified)

- [ ] **Step 1: Run make setup and capture output**

Run:
```bash
make setup 2>&1 | tee /tmp/asf-rebrand-make-setup.log | tail -30
```
Expected: the script runs end-to-end. Final section should contain `Verification:` lines (from the post-rebrand `setup-asf.sh`). Some `[WARN]` lines are acceptable (e.g. MCP server already registered) — the goal of this gate is "the renamed script still executes", not "zero warnings".

- [ ] **Step 2: Confirm the banner now says ASF**

Run:
```bash
grep 'ASF — Agentic SDLC Framework Setup' /tmp/asf-rebrand-make-setup.log
```
Expected: one matching line. If it still says `VSAF`, Task 2 missed `scripts/setup-vsaf.sh` content — STOP and investigate.

- [ ] **Step 3: Confirm no stray `vsaf` in the run log**

Run:
```bash
grep -c 'vsaf\|VSAF' /tmp/asf-rebrand-make-setup.log || true
```
Expected: `0`. A non-zero count means either the script or one of its printed file paths still carries the old brand.

---

## Task 8: Create the atomic commit

**Files:** (committing all staged + unstaged changes from Tasks 2–4)

- [ ] **Step 1: Stage every modified and renamed file**

Run:
```bash
git add -u
git add scripts/setup-asf.sh
git status --short
```
(Note: `git add -u` stages modifications and deletions but does not stage new files. The renamed script was already staged by `git mv` in Task 3 but `git add scripts/setup-asf.sh` is a no-op safety net.)

Expected: status shows all 18 affected files staged (`M` for 13 rewrites, `R` for the script rename, `D` for 4 deletions) and nothing unstaged.

- [ ] **Step 2: Commit**

Run:
```bash
git commit -m "$(cat <<'EOF'
chore: rebrand VSAF to ASF (Agentic SDLC Framework)

- Rename VSAF/vsaf brand to ASF/asf across 14 content files
- Drop v3 version suffix from all headers
- Rename scripts/setup-vsaf.sh -> scripts/setup-asf.sh
- Delete 4 pre-rebrand historical spec/plan artifacts
- Clean re-index GitNexus under new repo name

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF
)"
```
Expected: commit succeeds. If a pre-commit hook fails, read the hook output, fix the issue, and create a NEW commit (do not amend).

- [ ] **Step 3: Verify the commit landed**

Run:
```bash
git log --oneline -1
git show --stat HEAD
```
Expected: the new commit is HEAD, stat shows ~18 files changed.

---

## Task 9: Post-commit final verification

**Files:** (none modified — read-only)

- [ ] **Step 1: Re-run Gate 1 against the committed state**

Run:
```bash
grep -rInI 'vsaf\|VSAF\|Vsaf' . \
  --exclude-dir=.git --exclude-dir=.gitnexus --exclude-dir=node_modules \
  && echo "FAIL: matches still present" || echo "OK: repo is clean"
```
Expected: `OK: repo is clean`.

- [ ] **Step 2: Confirm working tree is clean**

Run:
```bash
git status --short
```
Expected: empty output.

- [ ] **Step 3: Clean up ephemeral helper files**

Run:
```bash
rm -f /tmp/asf-rebrand-apply.py /tmp/asf-rebrand-before.txt /tmp/asf-rebrand-make-setup.log
```
Expected: no error.

- [ ] **Step 4: Summarize to user**

Report:
- Commit SHA (from `git log --oneline -1`)
- Files changed count
- Gates 1–5 status (all OK)
- Reminder that the user still needs to manually rename the GitHub repo (out-of-scope per the spec)

---

## Rollback

If any gate fails mid-plan and you need to abort before the Task 8 commit:

```bash
git checkout -- .
git clean -fd scripts/ docs/
# restore deleted historical files from HEAD
git checkout HEAD -- \
  docs/superpowers/specs/2026-04-14-claude-settings-hardening-design.md \
  docs/superpowers/specs/2026-04-14-fix-make-setup-warnings-design.md \
  docs/superpowers/plans/2026-04-14-claude-settings-hardening.md \
  docs/superpowers/plans/2026-04-14-fix-make-setup-warnings.md
rm -rf .gitnexus
```

After Task 8 commits, rollback is `git revert HEAD` (do not force-reset on `main`).
