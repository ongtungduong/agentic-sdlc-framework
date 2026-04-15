# ASF INSTRUCTION — Advanced Usage Guide

> **Audience:** Developers new to this repo AND new to Claude Code.
> **Goal:** Teach you how to *wield* the 8 ASF tools together, not just run their commands.
> **Complements:** [1-setup-guide.md](1-setup-guide.md) (install + overview). Read that first if you haven't.
> **See also:** [README.md](../../README.md) (project overview) · [3-cheatsheet.md](3-cheatsheet.md) (1-page command ref) · [4-milestones.md](4-milestones.md) (Day 1/Week 1/Month 1) · [5-faq.md](5-faq.md) (mindset FAQ)

This guide answers three questions the overview doesn't:
1. **When** do I reach for each tool? (not just "what does it do")
2. **How** do I combine tools so they reinforce each other?
3. **What** does a real end-to-end SDLC cycle look like, command by command?

---

## Table of Contents

1. [Start Here — 5-Minute Orientation](#1-start-here)
2. [Tool-by-Tool Deep Dive](#2-tool-by-tool-deep-dive)
3. [Coordination Playbooks](#3-coordination-playbooks)
4. [Full SDLC Demo — JWT Refresh Token Rotation](#4-full-sdlc-demo)
5. [Advanced Tips](#5-advanced-tips)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. Start Here

### The Mental Model

Forget "AI autocomplete." ASF treats Claude Code as a disciplined team member who must:

```
    SPEC  ─────►  PLAN  ─────►  TDD  ─────►  3-LAYER REVIEW  ─────►  SHIP
    (what)       (how)        (code)      (methodology/spec/graph)
```

Every feature passes through every stage. Bug fixes take a shortcut (Quick Flow: skip spec, keep plan + TDD + review). Nothing ships without Layer 2 (spec compliance) passing.

### The 4 Layers and 8 Tools

| Layer | Tools | Your job |
|---|---|---|
| **Planning** | BMAD + OpenSpec | Turn ideas into verifiable specs |
| **Code Intel** | GitNexus + Graphify | Know what breaks before you break it |
| **Memory** | claude-mem + MemPalace | Never re-learn the same thing twice |
| **Implementation** | Claude Code + Superpowers + ECC | Code with guardrails |

### Decision Matrix — "Which tool do I reach for?"

| Situation | First tool | Why |
|---|---|---|
| "I don't understand this codebase" | Graphify (`GRAPH_REPORT.md`) | Structural overview in one file |
| "What breaks if I change `X`?" | GitNexus (`gitnexus_impact`) | Call-graph-aware blast radius |
| "Why did we choose `X` over `Y`?" | MemPalace (`mempalace_search`) | Verbatim decision history |
| "What did I do yesterday?" | claude-mem (auto-injected) | Session recall, zero config |
| "I have a vague idea" | BMAD (`*agent analyst`) | Turns ideas into requirements |
| "I have requirements, need a spec" | OpenSpec (`/opsx:propose`) | Proposal → design → tasks |
| "I have a spec, need a plan" | Superpowers (`/superpowers:write-plan`) | Atomic task list with verification |
| "I have a plan, need code" | Superpowers (`/superpowers:execute-plan`) | TDD cycles, 1 commit per task |
| "I'm done, pre-PR check" | `make review` | 3-layer review |
| "I merged, now what?" | `make archive` | Archive + re-index |

**Rule of thumb:** If you're typing code before you've touched *any* tool in this table, stop.

---

## 2. Tool-by-Tool Deep Dive

Each tool section follows the same five-part structure: **Purpose → When it's mandatory → Advanced commands → Anti-patterns → Combines with**.

### 2.1 BMAD Method (Planning Agents)

**Purpose:** AI personas that mirror a real agile team — Analyst, PM, Architect, Product Owner, Dev, UX, Tech Writer — each with their own tasks and outputs.

**Mandatory when:**
- Starting any feature bigger than a bug fix.
- Stakeholder requirements are vague or conflicting.
- You need a PRD, architecture doc, or sprint stories.

**Advanced commands (beyond `*agent analyst`):**

| Command | What it unlocks |
|---|---|
| `bmad-brainstorming` | Structured ideation before even calling analyst — produces idea list + ranking |
| `bmad-product-brief` | One-page brief for stakeholders before a full PRD |
| `bmad-prfaq` | Amazon-style "Working Backwards" press release — great for contested scope |
| `bmad-domain-research` | Offloads industry/domain research to a sub-agent |
| `bmad-check-implementation-readiness` | Validates PRD + arch + UX + tests *together* before coding |
| `bmad-review-edge-case-hunter` | Walks every branching path to find untested edges |
| `bmad-retrospective` | Post-epic review — feed lessons into MemPalace |
| `bmad-correct-course` | When scope shifts mid-sprint, re-aligns all artifacts instead of discarding them |

**Anti-patterns:**
- Calling `*agent dev` to write code before PM/Architect have finished. The dev agent assumes PRD and arch exist.
- Using BMAD for a one-line bug fix. Quick Flow skips BMAD entirely.
- Editing BMAD outputs by hand without re-running `bmad-check-implementation-readiness` — downstream artifacts go stale.

**Combines with:**
- BMAD outputs (`docs/prd.md`, `docs/architecture.md`) are the *input* to OpenSpec `/opsx:propose`.
- BMAD Architect's diagrams feed Graphify updates — re-run `/graphify . --update` after arch changes.
- Save non-obvious decisions from BMAD retrospectives into MemPalace with `mempalace_add_drawer`.

---

### 2.2 OpenSpec (Spec-Driven Development)

**Purpose:** Force every change through a written proposal, design, and task list that can be verified automatically.

**Mandatory when:** Touching any code not covered by Quick Flow.

**Advanced commands:**

| Command | What it unlocks |
|---|---|
| `/opsx:explore` | Thinking partner *before* propose — dumps scratchpad, no artifacts yet |
| `/opsx:propose <name>` | Creates `openspec/changes/<name>/` with proposal, design, tasks |
| `/opsx:apply` | Implements the task list (usually delegated to Superpowers instead) |
| `/opsx:archive` | Moves approved changes into `openspec/specs/` — canonical spec store |
| `openspec validate --all` | Layer 2 of the 3-layer review |
| `openspec list` | Shows all active (non-archived) changes — run in `make status` |

**Anti-patterns:**
- Writing code without a proposal. The proposal is *not* overhead — it's the contract Layer 2 verifies against.
- Archiving before the PR merges. Archive *after* merge, in `make archive`.
- Skipping `/opsx:explore` for complex scope. Explore is free thinking; propose is a commitment.

**Combines with:**
- Proposal content is drafted by BMAD agents first, then formalized by `/opsx:propose`.
- Each task in the task list should get one GitNexus impact check before execution.
- Superpowers `write-plan` reads OpenSpec tasks and expands each into atomic TDD steps.
- `make verify` (Layer 2) runs `openspec validate --all`. Failure here means: **stop, go fix, don't push.**

---

### 2.3 Superpowers (Methodology Engine)

**Purpose:** A library of skills that enforce engineering discipline — brainstorming, planning, TDD, code review, debugging — via Claude Code's Skill tool.

**Mandatory when:** Any implementation task. Always.

**Advanced commands (beyond brainstorm/write-plan/execute-plan):**

| Skill | Use when |
|---|---|
| `superpowers:systematic-debugging` | You've hit the same bug twice — forces hypothesis → experiment → conclusion |
| `superpowers:test-driven-development` | Red-green-refactor enforcement; invoked by execute-plan but usable standalone |
| `superpowers:subagent-driven-development` | Long implementation plan — dispatch tasks to sub-agents in parallel |
| `superpowers:dispatching-parallel-agents` | 2+ independent tasks (e.g., "research 3 libraries", "audit 4 files") |
| `superpowers:verification-before-completion` | Before you claim a task done — forces explicit verification steps |
| `superpowers:requesting-code-review` | On task completion — structured handoff to code-reviewer |
| `superpowers:receiving-code-review` | When a reviewer pushes back — forces systematic response |
| `superpowers:using-git-worktrees` | Parallel feature branches without polluting main worktree |
| `superpowers:finishing-a-development-branch` | Pre-PR checklist — runs review, verify, index, scan |

**Anti-patterns:**
- Skipping `brainstorm` "because the task is simple." Simple tasks are where unexamined assumptions cause waste.
- Approving a plan that has tasks without verification steps. If you can't verify a task, you can't mark it done.
- Running `execute-plan` without a written plan. It will refuse — write the plan first.
- Ignoring a failing TDD red step. Red must fail for the *right reason* before you write code.

**Combines with:**
- `write-plan` consumes OpenSpec tasks; `execute-plan` produces 1 commit per task which triggers ECC hooks and (via PostToolUse) re-indexes GitNexus.
- `systematic-debugging` pairs with GitNexus `query` + `context` — the skill tells you *how* to investigate, GitNexus gives you *where* to look.
- `code-review` (Layer 1) runs before `make verify` (Layer 2) which runs before `make index` (Layer 3).

---

### 2.4 GitNexus (Code Intelligence MCP)

**Purpose:** Call-graph-aware code knowledge via MCP tools. Answers impact, context, and rename questions *without grepping.*

**Mandatory when:** Before editing any function, class, or method. Non-negotiable per `AGENTS.md`.

**Advanced commands:**

| Tool | Example | Beats |
|---|---|---|
| `gitnexus_query` | `{query: "token refresh"}` | grep across 50k LOC |
| `gitnexus_context` | `{name: "validateUser"}` | reading every caller manually |
| `gitnexus_impact` | `{target: "X", direction: "upstream"}` | guessing what breaks |
| `gitnexus_detect_changes` | `{scope: "staged"}` | "did I touch more than I thought?" |
| `gitnexus_rename` | `{symbol_name: "old", new_name: "new", dry_run: true}` | find-and-replace footguns |
| `gitnexus_cypher` | `{query: "MATCH (f:Function)-[:CALLS]->(g) WHERE ..."}` | custom call-graph queries |

**Risk levels:**

| Depth | Meaning | Rule |
|---|---|---|
| d=1 | WILL BREAK direct callers | MUST update them in the same PR |
| d=2 | LIKELY AFFECTED transitively | Must test |
| d=3 | MAY NEED TESTING | Test if on critical path |

**Anti-patterns:**
- Find-and-replace renames. Use `gitnexus_rename` — it understands the call graph.
- Ignoring HIGH/CRITICAL warnings. Report them to the user before proceeding.
- Forgetting `--embeddings` on re-index if the index previously had them. They get *deleted* silently.
- Committing without `gitnexus_detect_changes` — you might be shipping files you never intended.

**Combines with:**
- Impact analysis *before* Superpowers `write-plan` — your plan needs to cover d=1 callers.
- `detect_changes` *before* every commit in `execute-plan`.
- MCP resources (`gitnexus://repo/asf/process/<name>`) give step-by-step execution traces — feed those into `systematic-debugging`.

---

### 2.5 Graphify (Multimodal Knowledge Graph)

**Purpose:** Visual + textual knowledge graph of the whole corpus (code, docs, designs). Complements GitNexus: GitNexus is call-graph-exact; Graphify is fuzzy/semantic and multimodal.

**Mandatory when:**
- First day on the repo — read `graphify-out/GRAPH_REPORT.md`.
- After any architecture change — `/graphify . --update`.
- When tracing dependencies that cross module boundaries.

**Advanced commands:**

| Command | What it gives you |
|---|---|
| `/graphify .` | Full rebuild — use for first-time or major arch change |
| `/graphify . --update` | Incremental — uses semantic cache, 8.8x fewer tokens |
| `/graphify query "question"` | Natural-language structural query across the corpus |
| `/graphify path ServiceA ServiceB` | Shortest dependency path — great for "can A reach B?" |

**Reading `GRAPH_REPORT.md`:**
- **God nodes** — symbols with too many connections; refactor candidates.
- **Community cohesion** — modules with low cohesion are candidates for splitting.
- **Cross-community bridges** — edges that carry disproportionate coupling risk.
- **Suggested questions** — the report literally tells you what to ask it next.

**Anti-patterns:**
- Running `/graphify .` (full rebuild) when `--update` would do. The incremental path uses the semantic cache.
- Assuming Graphify is current if `make index` hasn't been run since your last merge.
- Using Graphify for exact call-graph questions — that's GitNexus' job.

**Combines with:**
- Graphify answers "how do these areas relate conceptually?" — GitNexus answers "which function calls which?" Use them in that order.
- After BMAD Architect publishes a new arch doc, `/graphify . --update` absorbs it into the graph so future queries find it.

---

### 2.6 claude-mem (Automatic Session Memory)

**Purpose:** Auto-captures what you did each session and re-injects compressed context on next start. Zero configuration. Web viewer at http://localhost:37777.

**Mandatory when:** Never manually. It runs by itself. Your job is to **not fight it.**

**Advanced usage:**
- `claude-mem:mem-search` — search across all past sessions by keyword.
- `claude-mem:timeline-report` — "Journey Into [Project]" narrative report.
- `claude-mem:knowledge-agent` — ask a question; it searches memory and synthesizes.
- `claude-mem:smart-explore` — token-optimized structural code search using memory as a cache.

**Anti-patterns:**
- **Duplicating claude-mem's work** by writing session summaries into MemPalace. claude-mem is for session recall; MemPalace is for decisions.
- Treating auto-injected context as ground truth for *current* state. Memory records freeze in time — verify against live code before acting.
- Dumping knowledge into `CLAUDE.md` instead of letting claude-mem handle it.

**Combines with:**
- claude-mem + MemPalace split: session facts → claude-mem, deliberate knowledge → MemPalace. Respect the split.
- Before starting work, read the `$CMEM` section that appears at session start. It lists recent session IDs you can expand with `get_observations([IDs])`.

---

### 2.7 MemPalace (Deliberate Knowledge Base)

**Purpose:** Verbatim, lossless storage for architecture decisions, team agreements, and domain knowledge. Temporal knowledge graph: old facts can be invalidated when the world changes. 19 MCP tools.

**Mandatory when:**
- Before answering "why did we choose X?" — search first.
- After making a non-obvious architecture decision — save it.
- At the end of meaningful sessions — diary entry.
- Weekly — mine conversations into the KG.

**Advanced commands:**

| Tool | Use |
|---|---|
| `mempalace_search` | Full-text + semantic search over all drawers |
| `mempalace_add_drawer` | Save a decision verbatim |
| `mempalace_check_duplicate` | Before adding — avoid noise |
| `mempalace_kg_query` | Query the temporal knowledge graph |
| `mempalace_kg_timeline` | See how a fact evolved over time |
| `mempalace_kg_invalidate` | Mark a fact as superseded |
| `mempalace_find_tunnels` | Surface surprising cross-wing connections |
| `mempalace_diary_write` | End-of-session journal entry |
| `mempalace_get_taxonomy` | List all wings/rooms/drawers for navigation |
| `mempalace mine ~/chats/ --mode convos` | Weekly — extract decisions from raw chat logs |

**Anti-patterns:**
- Using MemPalace for "what file did I edit yesterday" — that's claude-mem.
- Saving session summaries as drawers — drawers are for decisions and rationale, not activity logs.
- Never running `mempalace mine` — the KG goes stale and misses decisions from raw chats.
- Adding a drawer without `check_duplicate` — you'll end up with competing versions of the same fact.

**Combines with:**
- MemPalace is the memory layer for BMAD Architect and OpenSpec design docs. Save design rationale there, not in git commit messages alone.
- `mempalace_kg_invalidate` when an old decision is superseded by a new one — keeps downstream queries honest.

---

### 2.8 ECC (Everything Claude Code) Cherry-Pick

**Purpose:** AgentShield security scanner + pre-tool-use hooks that block secrets and protect config files + language-specific coding standard skills. Installed as a cherry-pick (no full ECC plugin).

**Mandatory when:**
- Every tool call (hooks run passively — just don't bypass them).
- Before every PR (`make scan`).
- Before every release (`make scan-deep` — Opus model, streaming).

**Advanced commands:**

| Command | Use |
|---|---|
| `npx ecc-agentshield scan` | Fast scan, 102 rules |
| `npx ecc-agentshield scan --opus --stream` | Deep scan for release candidates |
| Hooks in `.claude/settings.json` | Passive — block secrets, protect `.env`, guard MCP configs |
| Skill: `golang-patterns` | Idiomatic Go review |
| Skill: `rust-patterns` | Ownership + idiom review |
| Skill: `python-patterns` | PEP 8 + Pythonic review |
| Skill: `java-coding-standards` | Spring Boot conventions |
| Skill: `nestjs-patterns` | NestJS module architecture review |
| Skill: `nextjs-turbopack` | Next.js 16+ / Turbopack incremental build review |

**Anti-patterns:**
- Bypassing hooks with `--no-verify`. If a hook fires, investigate — don't suppress.
- Running only the fast scan before a release. `scan-deep` exists for a reason.
- Editing `.claude/settings.json` without knowing which hook does what. Read it first.

**Combines with:**
- ECC skills (language patterns) are invoked by Superpowers `code-review` for language-appropriate review.
- AgentShield runs as part of `make review` pipeline (pre-PR) and `githooks/pre-push`.

---

## 3. Coordination Playbooks

Five composite workflows. Each uses multiple tools in a specific order. Memorize these — they're the ones you'll use daily.

### Playbook A: "I don't understand this code"

```
1. cat graphify-out/GRAPH_REPORT.md             # 5-min structural overview
2. /graphify query "how does <feature> work?"   # Natural-language corpus query
3. gitnexus_query({query: "<feature keywords>"}) # Call-graph flows
4. gitnexus_context({name: "<entrypoint>"})     # 360° view of the suspect symbol
5. READ gitnexus://repo/asf/process/<name>     # Step-by-step execution trace
6. mempalace_search("why <feature>")            # Historical rationale
```

**Why this order:** Broad → narrow. Graphify gives shape; GitNexus gives exact edges; MemPalace gives *why*. Don't skip to GitNexus context before you have shape — you'll get lost.

### Playbook B: "I'm about to refactor"

```
1. gitnexus_context({name: "target"})                     # What calls it, what it calls
2. gitnexus_impact({target: "target", direction: "upstream"})  # Blast radius
3. /graphify path <target> <suspect dependent>            # Confirm path if unsure
4. mempalace_search("<target> history")                   # Any past refactor attempts?
5. /opsx:propose refactor-<target>                        # Written spec with impact summary
6. /superpowers:brainstorm                                # 2-3 approaches + trade-offs
7. /superpowers:write-plan                                # Atomic task list
8. /superpowers:execute-plan                              # TDD cycles
9. gitnexus_detect_changes({scope: "staged"})             # Scope check before commit
10. make review                                           # 3-layer review
```

**Gotcha:** If step 2 returns d=1 callers you didn't expect, go back to step 5 and expand the proposal. Don't "just handle it inline."

### Playbook C: "I'm debugging"

```
1. [auto] claude-mem injects recent session context       # You may already have a clue
2. claude-mem:mem-search "<error message>"                # Have we seen this before?
3. gitnexus_query({query: "<symptom>"})                   # Find related execution flows
4. gitnexus_context({name: "<suspect function>"})         # See callers/callees
5. READ gitnexus://repo/asf/process/<processName>        # Trace the flow
6. /superpowers:systematic-debugging                      # Hypothesis → experiment → conclusion
7. gitnexus_detect_changes({scope: "compare", base_ref: "main"})  # What changed on this branch?
8. [fix]  /superpowers:test-driven-development            # Write a failing test first
9. mempalace_add_drawer                                   # Save the root cause if non-obvious
```

**Why this order:** Memory first (cheap), graph second (structural), methodology third (discipline), code last.

### Playbook D: "Brand-new feature"

```
Step 0:  make status                           # Tools healthy?
Step 1:  read GRAPH_REPORT.md + mempalace_search <domain>
Step 2:  *agent analyst                        # Scope
Step 3:  *agent pm + *agent architect          # PRD + arch
Step 4:  /opsx:propose <feature>               # Spec + design + tasks
         /opsx:ff                              # Fast-forward artifacts
Step 5:  gitnexus_impact on every touched symbol
         /graphify path <new> <existing>       # Integration points
Step 6:  /superpowers:brainstorm               # Trade-offs
         /superpowers:write-plan               # Atomic tasks
Step 7:  /superpowers:execute-plan             # TDD, 1 commit/task
         [ECC hooks fire passively]
Step 8:  /superpowers:code-review              # Layer 1
         make verify                           # Layer 2
         make index                            # Layer 3
         make scan                             # Security gate
Step 9:  git push                              # pre-push hook re-runs verify + scan
Step 10: make archive && make mine             # Archive specs, mine decisions
```

See Section 4 for a full worked example of this playbook.

### Playbook E: "I just merged something"

```
1. git pull
2. make index                 # GitNexus + Graphify re-index
3. make archive               # Move completed changes into openspec/specs/
4. mempalace mine ~/chats/    # (Weekly, not every merge)
5. make status                # Confirm everything healthy
```

**Why:** Your local knowledge graph is stale the moment someone else merges. The 30 seconds this takes saves an hour of debugging an obsolete `gitnexus_impact` result.

---

## 4. Full SDLC Demo

### Feature: Add JWT refresh token rotation to the auth service

**Context:** Security team flagged that long-lived access tokens are a risk. We need to implement short-lived access tokens (15 min) with refresh tokens that rotate on use (reuse-detection revokes the whole family).

This walkthrough shows every ASF tool in one continuous flow. Real commands, realistic output snippets, and the gotchas a new dev will hit.

---

#### Step 0 — Pre-flight

```bash
make status
```

Expected output: all 8 tools report healthy. If GitNexus says "not indexed," run `gitnexus analyze` first. If MemPalace says "not initialized," you skipped setup — run `make setup`.

**Gotcha:** `make status` can pass even if `graphify-out/` is stale. Check modification time — if older than the last merge, run `make index`.

---

#### Step 1 — Understand the codebase

```bash
cat graphify-out/GRAPH_REPORT.md | less
```

Look for: the auth/session community, god nodes in the auth module, any cross-community bridges involving auth.

Then in Claude Code:

```
/graphify query "how does the current auth flow issue tokens?"
```

Followed by:

```
gitnexus_query({query: "token issuance"})
gitnexus_context({name: "issueAccessToken"})
READ gitnexus://repo/asf/process/login-flow
```

Finally, check prior art:

```
mempalace_search("refresh token rotation")
mempalace_search("auth token decisions")
```

**Gotcha:** If MemPalace returns an old drawer that says "we chose sliding sessions over rotation in 2024," read it — you may be overturning a prior decision. If so, plan to `mempalace_kg_invalidate` it once the new design lands.

---

#### Step 2 — Scope

```
*agent analyst
```

The analyst asks clarifying questions. Answer them:
- Why now? → security audit finding.
- Constraints? → no breaking changes to mobile clients mid-flight.
- Success criteria? → reuse detection revokes family within 1s; tests prove rotation.
- Out of scope? → token encryption algorithm change.

```
*workflow-init
```

Choose **Standard Flow** (not Quick Flow) — this touches multiple modules and has security implications.

---

#### Step 3 — Plan

```
*agent pm
```

PM produces `docs/prd.md`:
- **FR-1** Access tokens expire in 15 min.
- **FR-2** Refresh tokens rotate on every use.
- **FR-3** Reuse of a consumed refresh token revokes the entire token family.
- **FR-4** Mobile clients on old API remain functional for 90 days.
- **NFR-1** Rotation latency < 50ms p99.
- **NFR-2** Revocation propagates across all instances in < 1s.

```
*agent architect
```

Architect produces `docs/architecture/auth-refresh-rotation.md`:
- Token family model (parent_id linking chains).
- Redis-backed revocation list with 90-day TTL.
- Middleware change in `AuthGuard`.
- Migration strategy: dual-write old + new claims for 30 days.

```bash
git add docs/ && git commit -m "feat: PRD + arch for refresh token rotation"
```

**Gotcha:** Commit BMAD outputs immediately. You'll want them in the OpenSpec proposal context in the next step, and `execute-plan` needs them on disk.

---

#### Step 4 — Specs

```
/opsx:propose refresh-token-rotation
```

This creates `openspec/changes/refresh-token-rotation/` with `proposal.md`, `design.md`, and `tasks.md`. Review the task list — each task must be atomic (2–5 min of work) and have a verification step.

```
/opsx:ff
```

Fast-forwards related artifacts so every doc points at the same version.

```bash
git add openspec/ && git commit -m "spec: refresh token rotation"
```

**Gotcha:** If a task lacks a verification step, don't approve the proposal — send it back to `/opsx:propose` for revision. Superpowers `execute-plan` will refuse to run tasks without verification.

---

#### Step 5 — Impact analysis

In Claude Code:

```
gitnexus_impact({target: "AuthGuard", direction: "upstream"})
```

Example output:
- d=1: `AppModule`, `AdminModule`, `BillingModule`, `MobileApiController`
- d=2: 23 route handlers
- d=3: transitive across 80% of the codebase
- **Risk: HIGH**

Report this to the user. **Do not proceed silently.**

```
gitnexus_impact({target: "issueAccessToken", direction: "upstream"})
/graphify path AuthGuard MobileApiController
```

Check for past attempts:

```
mempalace_search("AuthGuard refactor")
```

**Decision gate:** HIGH impact means we split the PR. Go back to `/opsx:propose` and split into:
1. `refresh-token-model` (data layer only)
2. `refresh-token-issuance` (service layer)
3. `refresh-token-middleware` (AuthGuard change behind a feature flag)
4. `refresh-token-rollout` (enable flag, migrate clients)

Re-run `/opsx:ff` after splitting.

**Gotcha:** "Impact > 3 modules → split PRs" is in `CLAUDE.md`. This is not optional.

---

#### Step 6 — Brainstorm + plan (for sub-PR #1: `refresh-token-model`)

```
/superpowers:brainstorm
```

The brainstorm skill asks clarifying questions and proposes 2–3 approaches:
- **A.** Single table `refresh_tokens(parent_id, family_id, consumed_at)`.
- **B.** Two tables: `token_families` + `refresh_tokens`.
- **C.** Redis-only with periodic snapshot to Postgres.

Trade-offs discussed. Pick **B** (clean separation, easy to index).

```
/superpowers:write-plan
```

Plan is written to `docs/superpowers/plans/refresh-token-model.md`. Every task has a verification step ("test X passes", "migration applies cleanly on a fresh DB", "`gitnexus_detect_changes` shows only these files").

Review the plan. Approve it explicitly.

**Gotcha:** `write-plan` will produce garbage if you skip `brainstorm`. The skill priority ordering (process skills before implementation skills) exists for a reason.

---

#### Step 7 — Execute

```
/superpowers:execute-plan
```

The skill runs RED → GREEN → REFACTOR per task:
1. **RED:** write a failing test. Verify it fails for the right reason.
2. **GREEN:** minimal code to make it pass.
3. **REFACTOR:** clean up without breaking the test.
4. **COMMIT:** one commit per task, message follows `<type>: <description>`.

During execution:
- ECC hooks block any accidental secret or config write.
- PostToolUse hook re-indexes GitNexus after each commit.
- claude-mem auto-captures what you did.

**Gotcha:** If a task fails 3 times in a row, STOP. Don't hammer at it. Trigger an architectural review — something in the plan is wrong. Update the plan, don't brute-force the task.

---

#### Step 8 — 3-layer review

```
/superpowers:code-review
```

Layer 1 (methodology): checks code against the plan, ECC coding-standard skills (`nestjs-patterns` for the NestJS parts), and architectural consistency.

```bash
make verify
```

Layer 2 (spec compliance): `openspec validate --all`. If this fails, go back to Step 7.

```bash
make index
```

Layer 3 (graph sync): re-index so GitNexus + Graphify reflect the new code.

```bash
make scan
```

Security gate before PR.

**Gotcha:** Run these *in order*. Layer 1 catching a methodology issue is cheap; Layer 2 catching a spec drift after you've already pushed is expensive.

---

#### Step 9 — Push

```bash
git push origin feature/refresh-token-model
```

`githooks/pre-push` auto-runs `make verify` + `make scan`. If either fails, push is blocked. Fix locally — **do not** bypass with `--no-verify`.

PR description template:
```
## Summary
Adds token family + refresh_tokens tables for refresh token rotation.

## OpenSpec proposal
openspec/changes/refresh-token-model/proposal.md

## Impact
- d=1: migrations runner, AuthModule tests
- d=2: none (behind feature flag)
- HIGH risk mitigated by splitting into 4 PRs; this is PR 1/4.

## Tests
- 14 new tests, all passing
- Migration applies on fresh DB in < 200ms
- `openspec validate --all`: passing
```

---

#### Step 10 — Archive + ship

After PR merges:

```bash
git pull
make archive      # openspec archive + re-index
make mine         # mine decisions from ~/chats/ into MemPalace (weekly)
```

For release:

```bash
make scan-deep    # Opus + streaming
git tag v1.4.0 && git push --tags
```

Save the final decision into MemPalace for future you:

```
mempalace_add_drawer
  wing: architecture
  room: auth
  drawer: refresh-token-rotation-v1
  content: "Chose token-family model B (two tables) over Redis-only (C)
            because Postgres is the source of truth and Redis availability
            is not guaranteed during regional failover. Family_id indexed
            for O(1) revocation. 90-day TTL matches compliance retention.
            Split into 4 PRs because AuthGuard impact was HIGH (23 d=2
            route handlers). See openspec/specs/refresh-token-* for details."
```

If you're superseding an old decision:

```
mempalace_kg_invalidate <old-drawer-id>
```

**Done.** The next dev who asks "why did we rotate refresh tokens?" gets a full answer in one search.

---

## 5. Advanced Tips

### Parallel work with worktrees

When you need to work on two features without context switching:

```
/superpowers:using-git-worktrees
```

Creates an isolated worktree. Your main worktree stays clean. Great for: running `execute-plan` in one worktree while exploring an unrelated bug in another.

### Parallel agents for independent research

When you have 2+ independent questions ("audit these 4 files", "research these 3 libraries"):

```
/superpowers:dispatching-parallel-agents
```

The skill dispatches sub-agents concurrently. Don't use for dependent tasks — only when results are genuinely independent.

### Subagent-driven execution for long plans

For 20+ task plans, instead of sequential `execute-plan`:

```
/superpowers:subagent-driven-development
```

Dispatches tasks to sub-agents with a two-phase review pipeline. Each sub-agent gets a self-contained prompt; you review their summary before merging.

### Weekly hygiene

| Cadence | Command | Why |
|---|---|---|
| Every merge | `make index` | GitNexus + Graphify stay fresh |
| Every merge | `make archive` | Keep `openspec/changes/` small |
| Weekly | `make mine` | Extract decisions from raw chats into MemPalace |
| Weekly | `mempalace_find_tunnels` | Surface surprising cross-wing connections |
| Monthly | `make scan-deep` | Deep security audit |
| Release | `make scan-deep` | Mandatory pre-release gate |

### Reading `GRAPH_REPORT.md` productively

Don't read top-to-bottom. Jump to these sections first:
1. **Suggested questions** — literally tells you what to ask next.
2. **God nodes** — refactor candidates, high blast radius.
3. **Cross-community bridges** — coupling risk.
4. **Communities** — module map.

---

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| `gitnexus_impact` returns "index stale" | Someone else merged | `gitnexus analyze` (or `make index`) |
| `gitnexus_impact` missing callers you know exist | No embeddings | `gitnexus analyze --embeddings` |
| `/graphify . --update` complains about cache | Backup deleted before diff | Run full `/graphify .` once, then resume incremental |
| `make verify` fails after `execute-plan` | Spec drifted from code | Don't edit spec to match — fix code to match spec |
| PreToolUse hook blocks every action | Broken JSON in `.claude/settings.json` | Validate with `jq '.' .claude/settings.json` |
| MemPalace returns stale facts | Fact superseded but not invalidated | `mempalace_kg_invalidate <drawer-id>` |
| claude-mem not injecting context | Session viewer not running | Check http://localhost:37777; restart Claude Code |
| ECC skill "not found" warnings on `make setup` | Upstream skill path changed | Already fixed — pull latest, re-run `make setup` |
| `make archive` fails with "no approved changes" | You archived before merge | Archive only *after* PR merges |
| `execute-plan` refuses to start | Plan has tasks without verification | Re-run `write-plan` with verification gates |
| `gitnexus_rename` dry-run shows unexpected hits | `text_search` fallback matched a string literal | Review and either approve or skip individually |
| Layer 2 review passes but code is wrong | Spec is wrong | Update the spec via `/opsx:propose` revision, not code |
| Hooks fire on legitimate files | Path glob too broad | Read `.claude/settings.json`, tighten the glob, don't add `--no-verify` |

---

## Core Principles (memorize these)

1. **Spec before code.** Always. Quick Flow is the only exception and it still needs a plan.
2. **Context is king.** Read Graphify + GitNexus + MemPalace *before* touching code.
3. **Git is the source of truth.** Commit BMAD outputs, OpenSpec artifacts, and plans as you go.
4. **3-layer review before every PR.** Methodology → spec → graph sync.
5. **Re-index after every merge.** `make index`.
6. **Mine decisions weekly.** `make mine`.
7. **Never bypass hooks.** If a hook fires, the hook is right until proven otherwise.
8. **Split when impact is HIGH.** PRs > 400 lines or > 3 modules get split.
9. **Memory has a split.** claude-mem = sessions. MemPalace = decisions. Don't cross the streams.
10. **If a task fails 3 times, stop.** Architectural problem, not an execution problem.

---

**Next steps for a new dev:**
1. Run `make setup` and `make status`.
2. Read [1-setup-guide.md](1-setup-guide.md) cover to cover.
3. Re-read Section 4 of this file (the JWT demo) — understand every command before you touch real code.
4. Pick a trivial first task (typo fix, doc update). Run it through the Quick Flow.
5. Then pick a small feature. Run it through the Standard Flow from Section 4.
6. Ask questions. They're cheaper than re-doing a PR.
