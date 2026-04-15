# ASF FAQ

> Answers to the questions every new developer asks — about mindset, not commands.
> For tool commands, see [3-cheatsheet.md](3-cheatsheet.md).
> For deep operational knowledge, see [2-workflow-guide.md](2-workflow-guide.md).

---

### Can I skip brainstorm for a simple task?

No. Simple tasks are where unchecked assumptions cause the most waste. Brainstorm
takes 2 minutes and often reveals something you hadn't considered. The rule is
absolute: `/superpowers:brainstorm` before every implementation, no matter how
small.

---

### When do I use Quick Flow vs Standard Flow?

**Quick Flow** = bug fixes and trivial changes (typo, doc update, 1-liner fix).
It skips planning (Steps 3–5) but keeps brainstorm, TDD, and 3-layer review.

**Standard Flow** = anything that touches logic, adds a feature, or changes
behavior. If you're unsure, use Standard — the extra steps catch problems before
they reach code.

Rule of thumb: if you need more than one commit, it's Standard.

---

### Does a solo developer need the full workflow?

Yes. The workflow is not about team coordination — it's about preventing mistakes.
Solo developers skip peer review (Step 9 is self-review), but every other step
applies. Spec drift, forgotten edge cases, and stale knowledge graphs affect
solo developers just as much. The 3-layer review is mandatory even for teams of
one.

---

### Can I write code first and spec later?

No. This is the #1 anti-pattern in ASF. Without a spec, Layer 2 (`make verify`)
has nothing to verify against, so you have no way to catch spec drift. Specs
are not overhead — they are the contract that makes automated verification
possible.

Exception: Quick Flow skips specs but still requires a plan with verification
steps.

---

### What if I disagree with a BMAD agent's output?

Push back. BMAD agents are interactive — they ask questions and present drafts
for your approval. If the PM's PRD has a requirement you think is wrong, say so.
If the Architect's design feels over-engineered, challenge it. You are the human
in the loop. Never accept output you haven't reviewed.

After editing BMAD output, re-run `bmad-check-implementation-readiness` to
ensure downstream artifacts are still consistent.

---

### What if `gitnexus_impact` returns HIGH or CRITICAL?

**Stop and report to the team before proceeding.** HIGH/CRITICAL means your
change has a large blast radius (many direct callers, many affected modules).

The rule is: impact > 3 modules → split into smaller PRs. Go back to
`/opsx:propose` and break the change into independent pieces, each targeting a
smaller scope. Use feature flags if you need to deploy incrementally.

Never silently proceed past a HIGH/CRITICAL warning.

---

### Do I really need to run `make index` after every merge?

Yes. The GitNexus knowledge graph and Graphify report are local. The moment
someone else merges code, your local index is stale. Running `gitnexus_impact`
on a stale index gives wrong answers — you could miss a dependent that will
break. 30 seconds of re-indexing saves hours of debugging.

---

### What's the difference between `make verify` failing and `make scan` failing?

- **`make verify` failure** = your code does not match the OpenSpec specs. This
  means spec drift — your implementation diverged from what was designed. Fix the
  code, not the spec (unless the spec was wrong, in which case update the spec
  via `/opsx:propose` revision first).

- **`make scan` failure** = security issue detected by AgentShield. Could be
  hardcoded secrets, insecure patterns, or config exposure. Fix the vulnerability
  before pushing.

Both block `git push` via the pre-push hook. Neither should be bypassed with
`--no-verify`.

---

### When should I store something in MemPalace vs just relying on claude-mem?

**claude-mem** captures automatically: what files you edited, what commands you
ran, debug context. It uses lossy compression — reasoning chains may be
simplified. Good for "what did I do yesterday?"

**MemPalace** stores deliberately: architecture decisions, design rationale, why
you chose approach A over B. It stores verbatim, lossless, with temporal
awareness. Good for "why did we choose Patroni over Stolon?"

Rule: if a future developer would benefit from knowing the *reasoning* behind a
choice, store it in MemPalace. If it's just session activity, claude-mem already
has it.

---

### What if a hook blocks something I think is legitimate?

Investigate before bypassing. Read the hook rules in `.claude/settings.json` to
understand what triggered. Common cases:

- **Secret detection false positive** — if the string is genuinely not a secret,
  adjust the pattern in the hook config.
- **Protected file modification** — if you intended to modify a config file,
  understand why it's protected and whether your change is safe.

Never use `--no-verify` as a shortcut. If the hook is wrong, fix the hook
configuration.

---

### How do I handle a task that fails 3 times in a row?

Stop execution immediately. The 3-strike rule exists because repeated failure
means the task is poorly designed or the approach is fundamentally wrong. More
attempts won't fix it.

Instead:
1. Run `gitnexus_context` on the symbol you're struggling with.
2. Check if the plan assumed something incorrect.
3. Run `/superpowers:brainstorm` again with the new information.
4. Rewrite the failing task(s) in the plan.
5. Resume execution.

---

### Can I use ASF for non-code tasks (docs, configs, infra)?

Yes. The workflow scales down:
- **Doc changes**: Quick Flow. Brainstorm → plan → write → review.
- **Config changes**: Standard Flow + `make scan` (mandatory — config changes
  can expose secrets).
- **Infra**: Standard Flow. Architecture doc is especially important for infra
  changes.

The only difference is that TDD cycles may not apply to pure documentation —
but the brainstorm → plan → review pattern always applies.

---

### What if my PR is over 400 lines?

Split it. Large PRs are harder to review and more likely to introduce undetected
issues. This is a hard rule in ASF, not a suggestion.

Strategies for splitting:
- **By layer**: data model first, service layer second, API third.
- **By feature flag**: deploy behind a flag, activate later.
- **By module**: if impact analysis shows multiple modules, each module can be
  a separate PR.

Each sub-PR should pass `make verify` and `make scan` independently.

---

### Why does ASF have so many tools? Isn't this over-engineered?

Each tool solves a specific problem that the others don't:

| Without this tool | What goes wrong |
|---|---|
| BMAD | Requirements are vague, PRDs are missing, architecture is ad-hoc |
| OpenSpec | No way to verify code matches intent — spec drift is invisible |
| Superpowers | No methodology discipline — TDD and brainstorming get skipped |
| ECC | Secrets leak into commits, security rules are not enforced |
| GitNexus | "What breaks?" is answered by guessing instead of querying a graph |
| Graphify | No big-picture view of codebase structure, god nodes go unnoticed |
| claude-mem | Every session starts from scratch — no continuity |
| MemPalace | Architecture decisions live only in chat logs and get lost |

The overhead is ~30 seconds per step. The payoff is catching problems before
they become PRs that need to be reverted.
