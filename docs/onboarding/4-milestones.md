# ASF Onboarding Path

> Structured milestones for your first month. Each phase builds on the previous.

---

## Day 1 — Setup & Observe

**Goal:** Working environment, zero code changes.

- [ ] Run `make setup` — install all 8 tools
- [ ] Run `make status` — verify everything is green
- [ ] Install Superpowers inside Claude Code: `/plugin install superpowers@claude-plugins-official`
- [ ] Restart Claude Code
- [ ] Read `graphify-out/GRAPH_REPORT.md` — understand codebase structure
- [ ] Run `gitnexus serve` — browse the knowledge graph web UI
- [ ] Run `mempalace_search("architecture")` — see what decisions exist
- [ ] Read [2-workflow-guide.md](2-workflow-guide.md) Section 1 (Mental Model + Decision Table)
- [ ] Print [3-cheatsheet.md](3-cheatsheet.md) and pin it near your monitor

**Rule:** Do not modify any code on Day 1. Spend the day understanding.

**Checkpoint:** You can explain the 4 layers in your own words and you know
where to find the decision table.

---

## Days 2–3 — Quick Flow (First Real Task)

**Goal:** Complete one small change through the full Quick Flow cycle.

Pick something trivial: fix a typo, update a doc, correct a comment.

- [ ] Run `*agent analyst` — scope the fix
- [ ] Run `*workflow-init` — choose **Quick Flow**
- [ ] Run `/superpowers:brainstorm` — yes, even for a typo
- [ ] Run `/superpowers:write-plan` — get a plan with verification steps
- [ ] Run `/superpowers:execute-plan` — TDD cycle, 1 commit
- [ ] Run `/superpowers:code-review` — Layer 1
- [ ] Run `make verify` — Layer 2
- [ ] Run `make index` — Layer 3
- [ ] Run `make scan` — security gate
- [ ] Run `git push` — pre-push hook validates automatically

**Checkpoint:** Your first PR passes all 3 review layers and the pre-push hook
without manual intervention.

---

## Week 1 — Tool Familiarity

**Goal:** Use each tool at least once. Build muscle memory for the decision table.

- [ ] Query GitNexus: `gitnexus_impact` on any function — read the output
- [ ] Query Graphify: `/graphify query "how does <feature> work?"`
- [ ] Trace a path: `/graphify path <ServiceA> <ServiceB>`
- [ ] Search MemPalace: `mempalace_search("<any past decision>")`
- [ ] Read [2-workflow-guide.md](2-workflow-guide.md) Section 2 (Deep Dive) — skim all 8 tools
- [ ] Read [2-workflow-guide.md](2-workflow-guide.md) Section 4 (JWT Demo) — understand every command
- [ ] Read [5-faq.md](5-faq.md) — especially "Can I skip brainstorm?" and "Quick vs Standard"
- [ ] Run `make index` after a merge — observe the output
- [ ] Browse claude-mem web viewer at http://localhost:37777

**Checkpoint:** You can match any situation from the decision table to the
correct tool without looking at the cheatsheet.

---

## Week 2 — Standard Flow (First Feature)

**Goal:** Complete a small feature through the full Standard Flow.

Pick something with real logic: add a validation rule, create a new endpoint,
add a config option.

- [ ] Step 1: Read Graphify report + MemPalace search for the area you'll change
- [ ] Step 2: `*agent analyst` → `*workflow-init` → **Standard Flow**
- [ ] Step 3: `*agent pm` (PRD) → `*agent architect` (architecture doc)
- [ ] Step 4: `/opsx:propose <feature>` → `/opsx:ff` → commit specs
- [ ] Step 5: `gitnexus_impact` on every symbol you'll touch
- [ ] Step 6: `/superpowers:brainstorm` → `/superpowers:write-plan`
- [ ] Step 7: `/superpowers:execute-plan` — multiple TDD commits
- [ ] Step 8: 3-layer review (`make review`)
- [ ] Step 9: `git push`
- [ ] Step 10: After merge → `make archive`

**Checkpoint:** Your PR description includes the OpenSpec proposal link, impact
summary, and test results. `make verify` passes on first try.

---

## Week 3 — Collaboration Patterns

**Goal:** Use memory and intelligence tools in realistic scenarios.

- [ ] Debug something: follow Playbook C from [2-workflow-guide.md](2-workflow-guide.md) Section 3
- [ ] Store a decision: `mempalace_add_drawer` with real architecture rationale
- [ ] Run `make mine` — extract decisions from your conversation logs
- [ ] Check for stale facts: `mempalace_kg_query` on a topic you've worked on
- [ ] Use `gitnexus_detect_changes({scope: "staged"})` before a commit
- [ ] Read [2-workflow-guide.md](2-workflow-guide.md) Section 3 Playbooks A–E
- [ ] Try `/superpowers:systematic-debugging` if you encounter a bug

**Checkpoint:** You have at least one meaningful MemPalace drawer with a real
decision and its reasoning.

---

## Month 1 — Operating Independently

**Goal:** Work without looking up commands. Contribute to team knowledge.

- [ ] Complete a second Standard Flow feature without referring to docs mid-flow
- [ ] Handle an impact HIGH situation (split PR, revise proposal)
- [ ] Run a `bmad-retrospective` after a completed epic/feature
- [ ] Use `/superpowers:subagent-driven-development` or `dispatching-parallel-agents`
- [ ] Run `make scan-deep` before a release
- [ ] Help onboard another developer by pointing them to this path
- [ ] Verify weekly `make mine` is part of your routine

**Checkpoint:** You follow the 10 core principles from muscle memory. You
default to the correct tool for each situation without the decision table.

---

## Reading Order (Reference)

```
1. 1-setup-guide.md Section 3–4    ← Install, make setup, make status
2. 2-workflow-guide.md Section 1   ← Mental model, decision table
3. 2-workflow-guide.md Section 2   ← Deep dive 8 tools (skim, revisit later)
4. 2-workflow-guide.md Section 4   ← JWT demo (read carefully)
5. 3-cheatsheet.md                 ← Print, pin, refer daily
6. 5-faq.md                        ← Mindset questions
7. 2-workflow-guide.md Section 3   ← Playbooks (read when you hit a scenario)
8. 2-workflow-guide.md Section 5–6 ← Advanced tips + troubleshooting
```
