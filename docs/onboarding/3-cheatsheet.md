# ASF Cheatsheet

> Print this. Pin it next to your monitor. No explanations — just commands.

---

## Which Tool Right Now?

| I need to...                        | Run this                                    |
|-------------------------------------|---------------------------------------------|
| Understand the codebase             | `cat graphify-out/GRAPH_REPORT.md`          |
| Know what breaks if I change X      | `gitnexus_impact({target: "X", direction: "upstream"})` |
| Know why we chose X over Y          | `mempalace_search("X vs Y")`               |
| Recall what I did yesterday         | (auto) claude-mem injects at session start  |
| Turn a vague idea into requirements | `*agent analyst`                            |
| Turn requirements into specs        | `/opsx:propose <feature>`                   |
| Turn specs into a task plan         | `/superpowers:write-plan`                   |
| Execute the plan (TDD)              | `/superpowers:execute-plan`                 |
| Review before PR                    | `make review`                               |
| Clean up after merge                | `make archive && make index`                |

---

## Workflows

### Standard Flow (features)

```
*agent analyst → *workflow-init → Standard
*agent pm → *agent architect
/opsx:propose <feature> → /opsx:ff
gitnexus_impact on each symbol
/superpowers:brainstorm → /superpowers:write-plan
/superpowers:execute-plan
/superpowers:code-review → make verify → make index → make scan
git push
make archive && make mine
```

### Quick Flow (bug fixes)

```
*agent analyst → *workflow-init → Quick
/superpowers:brainstorm → /superpowers:write-plan
/superpowers:execute-plan
/superpowers:code-review → make verify → make index → make scan
git push
```

---

## Make Targets

| Command          | What                                       |
|------------------|--------------------------------------------|
| `make setup`     | Install / update all 8 tools               |
| `make status`    | Health check all tools                     |
| `make index`     | Re-index GitNexus + Graphify               |
| `make verify`    | Spec compliance check (Layer 2)            |
| `make review`    | Full 3-layer review                        |
| `make scan`      | Security scan (102 rules)                  |
| `make scan-deep` | Deep security scan (Opus + streaming)      |
| `make archive`   | Archive completed specs + re-index         |
| `make mine`      | Extract decisions → MemPalace              |

---

## BMAD Agents

| Command             | Agent     | Output                   |
|---------------------|-----------|--------------------------|
| `*agent analyst`    | Analyst   | Scope + requirements     |
| `*agent pm`         | PM        | PRD (FRs, NFRs, Epics)  |
| `*agent architect`  | Architect | Architecture doc         |
| `*agent po`         | PO        | Sprint stories           |
| `*workflow-init`    | —         | Choose Quick/Standard    |
| `bmad-help`         | —         | What to do next          |

---

## OpenSpec

| Command                  | What                                |
|--------------------------|-------------------------------------|
| `/opsx:explore`          | Scratchpad before committing        |
| `/opsx:propose <name>`   | Create proposal + design + tasks    |
| `/opsx:ff`               | Fast-forward all artifacts          |
| `/opsx:apply`            | Implement task list                 |
| `/opsx:verify`           | Check code matches specs            |
| `/opsx:archive`          | Archive completed change            |

---

## Superpowers

| Command                                   | When                       |
|-------------------------------------------|----------------------------|
| `/superpowers:brainstorm`                 | Before any implementation  |
| `/superpowers:write-plan`                 | After brainstorm           |
| `/superpowers:execute-plan`               | After plan approved        |
| `/superpowers:code-review`                | After coding (Layer 1)     |
| `/superpowers:systematic-debugging`       | Same bug twice             |
| `/superpowers:subagent-driven-development`| Plan 20+ tasks             |
| `/superpowers:finishing-a-development-branch` | Pre-PR checklist       |

---

## GitNexus

| Tool                      | For                          |
|---------------------------|------------------------------|
| `gitnexus_query`          | Find code by concept         |
| `gitnexus_context`        | 360° view of a symbol        |
| `gitnexus_impact`         | Blast radius before editing  |
| `gitnexus_detect_changes` | Pre-commit scope check       |
| `gitnexus_rename`         | Safe multi-file rename       |

Impact depth: **d=1** MUST fix · **d=2** should test · **d=3** test if critical

---

## 10 Core Principles

1. Spec before code. Always.
2. Read Graphify + GitNexus + MemPalace **before** touching code.
3. Commit BMAD output + OpenSpec artifacts immediately.
4. 3-layer review before every PR.
5. `make index` after every merge.
6. `make mine` weekly.
7. Never bypass hooks (`--no-verify`).
8. Split when impact HIGH (>3 modules or >400 lines).
9. claude-mem = sessions. MemPalace = decisions. Don't mix.
10. Task fails 3× → STOP. Architecture problem, not execution.

---

## Hygiene Schedule

| When       | Run                      |
|------------|--------------------------|
| Each merge | `make index`             |
| Each merge | `make archive`           |
| Weekly     | `make mine`              |
| Monthly    | `make scan-deep`         |
| Pre-release| `make scan-deep`         |
