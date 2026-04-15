# VSAF — Developer Onboarding Guide

> A complete guide for developers new to the VSAF framework.
> Covers what VSAF is, how to install it, and how to use it day-to-day.

### Related Docs

| Doc | Purpose |
|---|---|
| [README.md](../../README.md) | Project overview, quickstart, tool list |
| [2-workflow-guide.md](2-workflow-guide.md) | Advanced usage — deep dives, playbooks, anti-patterns, JWT demo |
| [3-cheatsheet.md](3-cheatsheet.md) | 1-page command reference (print and pin) |
| [4-milestones.md](4-milestones.md) | Day 1 / Week 1 / Month 1 milestones |
| [5-faq.md](5-faq.md) | Mindset questions every new dev asks |

---

## Table of Contents

1. [What is VSAF?](#1-what-is-vsaf)
2. [How the Tools Fit Together](#2-how-the-tools-fit-together)
3. [Prerequisites](#3-prerequisites)
4. [Installation](#4-installation)
5. [Your First Project — A Walkthrough](#5-your-first-project--a-walkthrough)
6. [Daily Operations Reference](#6-daily-operations-reference)
7. [Common Mistakes](#7-common-mistakes)
8. [Cost Summary](#8-cost-summary)
9. [Glossary](#9-glossary)

---

## 1. What is VSAF?

VSAF (Version-controlled Spec-driven Agentic Framework) is a development
framework built around Claude Code. It turns "ask the AI, copy-paste the output,
hope it works" into a structured, repeatable process:

1. **Write a spec first** — before any code is generated.
2. **Let AI agents plan** — analysts, PMs, and architects each do their job.
3. **Execute with guardrails** — TDD (Test-Driven Development) cycles with
   automatic security checks.
4. **Review in 3 layers** — methodology compliance, spec compliance, and
   knowledge-graph sync.
5. **Track decisions** — so you know *why* something was built a certain way six
   months from now.

### The 4-Layer Architecture

VSAF organizes its 8 tools into four layers. Each layer handles a different
concern:

```
┌──────────────────────────────────────────────────────────────────────┐
│  PLANNING          BMAD (agents) ──▶ OpenSpec (specs, tasks, verify) │
├──────────────────────────────────────────────────────────────────────┤
│  CODE INTEL        GitNexus (MCP backbone) + Graphify (multimodal)   │
├──────────────────────────────────────────────────────────────────────┤
│  MEMORY            claude-mem (auto) + MemPalace (knowledge base)   │
├──────────────────────────────────────────────────────────────────────┤
│  IMPLEMENTATION    Claude Code + Superpowers + ECC cherry-pick       │
└──────────────────────────────────────────────────────────────────────┘
```

- **Planning** — BMAD provides agile-style AI agents (Analyst, PM, Architect,
  Product Owner) that help you clarify requirements and write specs. OpenSpec
  turns those specs into structured proposals, designs, and atomic task lists.
- **Code Intelligence** — GitNexus builds a knowledge graph of your codebase via
  MCP (Model Context Protocol), so you can ask "what breaks if I change X?"
  Graphify adds a multimodal (visual + textual) knowledge graph with dependency
  path tracing.
- **Memory** — claude-mem automatically captures what you did in each session
  (files changed, commands run) and re-injects that context on your next
  session. MemPalace stores deliberate, permanent knowledge: architecture
  decisions, design rationale, team agreements.
- **Implementation** — Claude Code is your AI coding agent. Superpowers adds a
  methodology layer (brainstorm → plan → TDD → review). ECC (Everything Claude
  Code) cherry-pick provides security scanning and coding-standard hooks without
  the overhead of the full plugin.

### The 10-Step Workflow (Bird's-Eye View)

Every feature or bug fix follows this cycle. Bug fixes ("Quick Flow") skip steps
3–5.

| Step | What Happens | Key Command |
|------|-------------|-------------|
| 0 | One-time setup | `make setup` |
| 1 | Understand the codebase | Read `graphify-out/GRAPH_REPORT.md` |
| 2 | Scope the work | `*agent analyst` |
| 3 | Plan (PRD + architecture) | `*agent pm`, `*agent architect` |
| 4 | Write specs | `/opsx:propose <feature>` |
| 5 | Impact analysis | GitNexus MCP + Graphify queries |
| 6 | Brainstorm + plan tasks | `/superpowers:brainstorm` |
| 7 | Execute (TDD) | `/superpowers:execute-plan` |
| 8 | 3-layer self-review | `/superpowers:code-review` + `make verify` + `make index` |
| 9 | Push PR | `git push` with spec link + impact summary |
| 10 | Archive + ship | `make archive`, tag, deploy |

Each step is explained in detail in [Section 5](#5-your-first-project--a-walkthrough).

---

## 2. How the Tools Fit Together

### Tool Overview

| Tool | What It Does | Cost |
|------|-------------|------|
| **Claude Code** | The AI coding agent that runs in your terminal. Everything else plugs into it. | $20/mo |
| **BMAD Method** | Provides AI "team members" (Analyst, PM, Architect, PO) for planning. | Free |
| **OpenSpec** | Converts plans into structured specs, designs, and task lists. Verifies that your code matches the spec. | Free |
| **Superpowers** | Adds brainstorming, planning, TDD execution, and code review commands to Claude Code. | Free |
| **ECC cherry-pick** | Security scanner (AgentShield, 102 rules) + git hooks that block secrets and protect config files + coding standards for Go, Rust, and Python. | Free |
| **GitNexus** | Builds a code knowledge graph. Answers "what depends on X?" and "what breaks if I change Y?" via MCP. | Free |
| **Graphify** | Builds a multimodal knowledge graph with visual dependency maps. Can trace paths between services. | Free |
| **claude-mem** | Auto-pilot memory: captures every session automatically, re-injects context next time. Zero configuration. | Free |
| **MemPalace** | Knowledge base for deliberate storage: architecture decisions, design rationale, team agreements. Verbatim, lossless, with a temporal knowledge graph. | Free |

### Superpowers vs. ECC — What's the Difference?

These two tools seem similar at first glance, but they serve very different
purposes:

**Superpowers** is your *methodology engine*. It provides the workflow commands
you explicitly call during development:

- `/superpowers:brainstorm` — Socratic Q&A to explore alternatives before coding
- `/superpowers:write-plan` — Generates a step-by-step task list with
  verification steps
- `/superpowers:execute-plan` — Runs the plan using a RED → GREEN → REFACTOR TDD
  cycle
- `/superpowers:code-review` — Reviews your code against the plan, standards,
  and architecture

**ECC cherry-pick** is your *security guardrails*. It runs passively in the
background:

- **AgentShield** — On-demand security scanner with 102 rules
  (`npx ecc-agentshield scan`)
- **Git hooks** — Automatically block commits that contain secrets or modify
  protected config files
- **Language skills** — Coding standards for Go, Rust, and Python that Claude
  applies automatically

> **Why "cherry-pick"?** The full ECC plugin consumes too much of Claude's
> context window (reduces usable context from ~200K to ~70K tokens). VSAF
> installs only three components: AgentShield, hooks, and language skills.

### The Dual Memory Model

VSAF uses two memory systems because they solve different problems:

| | claude-mem | MemPalace |
|---|---|---|
| **How it works** | Runs automatically in the background. Zero configuration. | You explicitly add knowledge and search for it. |
| **What it stores** | Session history: files changed, commands run, debug context | Architecture decisions, design rationale, team knowledge |
| **Storage format** | AI-compressed summaries (may lose some reasoning detail) | Verbatim, lossless (preserves exact reasoning) |
| **Example question** | "What file did I edit yesterday?" | "Why did we choose Patroni over Stolon?" |
| **Temporal awareness** | No — flat history | Yes — can detect outdated facts and invalidate them |
| **Startup cost** | Auto-injects context at session start | 170 tokens at startup, then on-demand search |

**Rule of thumb:**
- If it happened in a coding session → claude-mem already captured it.
- If it's a decision worth remembering in 6 months → store it in MemPalace.

### GitNexus vs. Graphify — What's the Difference?

Both analyze your codebase, but in different ways:

- **GitNexus** is the **MCP backbone**. It parses your code's AST (Abstract
  Syntax Tree — the structural representation of your code), builds a knowledge
  graph, and exposes it to Claude Code via MCP. When you ask "what breaks if I
  change `PaymentService`?", GitNexus answers from its graph. It also provides a
  web UI (`gitnexus serve`) for browsing.

- **Graphify** is a **multimodal knowledge graph**. It generates a visual HTML
  graph (`graphify-out/graph.html`) and a human-readable report
  (`graphify-out/GRAPH_REPORT.md`). It can trace dependency paths between
  services (`/graphify path ServiceA ServiceB`) and identify "god nodes" — files
  or classes with too many connections.

**Use both.** GitNexus answers precise impact questions. Graphify gives you the
big picture and finds structural problems. Always re-index both after a merge
(`make index`).

---

## 3. Prerequisites

Before installing VSAF, make sure you have the following on your system. For
each item, there is a command you can run to verify.

| Requirement | Minimum Version | Check Command |
|---|---|---|
| Node.js | 18+ | `node -v` |
| npm | (comes with Node) | `npm -v` |
| Python | 3.10+ | `python3 --version` |
| pip3 | (comes with Python) | `pip3 --version` |
| pipx | any | `pipx --version` |
| git | any | `git --version` |
| jq | any | `jq --version` |
| Claude Code | active subscription | — |

**Operating system:** Ubuntu 24.x or macOS.

**Claude Code:** You need an active Claude Code subscription ($20/month). This
is the only paid component. All other tools are free.

**Why pipx?** Modern Linux distributions (PEP 668) prevent installing Python
packages globally with pip. pipx creates isolated environments for each tool
automatically. Install it with:

```bash
# Ubuntu/Debian
sudo apt install pipx
pipx ensurepath

# macOS
brew install pipx
pipx ensurepath
```

---

## 4. Installation

### Quick Path

If all prerequisites are installed, three commands set up everything:

```bash
git clone <repo-url> && cd vsaf
make setup          # Installs all 8 tools (idempotent — safe to re-run)
make status         # Verify everything is working
```

Then one manual step inside an interactive Claude Code session:

```
/plugin install superpowers@claude-plugins-official
```

Restart Claude Code after installing Superpowers.

That's it. The rest of this section explains what `make setup` does under the
hood, in case you need to debug or install tools individually.

### What `make setup` Does (Step by Step)

The setup script (`scripts/setup-vsaf.sh`) is idempotent: running it multiple
times is safe. It skips tools that are already installed.

#### 4.1 BMAD Method

```bash
npx bmad-method install
```

Installs agile AI agent definitions into your project. After this, you will see
a `.bmad` directory or `.bmad-method.json` in your project root. These define
the Analyst, PM, Architect, and PO agents you can invoke with `*agent <role>`.

#### 4.2 OpenSpec

```bash
npm install -g @fission-ai/openspec@latest
openspec init
```

Installs the OpenSpec CLI globally and initializes an `openspec/` workspace in
your project. This workspace holds proposals, specs, designs, and task lists.
You interact with it through slash commands like `/opsx:propose`.

#### 4.3 ECC Cherry-Pick

```bash
# Temporary clone (removed after install)
git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git /tmp/ecc
```

The setup script extracts three things from the ECC repository:

1. **Hooks** — Merged into `~/.claude/settings.json`. These are `PreToolUse`
   and `PostToolUse` hooks that automatically block commits containing secrets
   and protect critical config files.

2. **Language skills** — Copied to `~/.claude/skills/`. These are coding
   standards for Go, Rust, and Python that Claude Code applies when generating
   code in those languages.

3. **AgentShield** — No installation needed. You run it on-demand with
   `npx ecc-agentshield scan`.

The temporary clone is deleted after extraction.

> **Why not install the full ECC plugin?** The full plugin adds extensive context
> that reduces Claude's usable context window from ~200K to ~70K tokens. By
> cherry-picking only these three components, you get the security benefits
> without the context overhead.

#### 4.4 GitNexus

```bash
npm install -g gitnexus
gitnexus setup
gitnexus analyze .
gitnexus analyze --skills
```

Installs GitNexus globally, runs its initial setup, and indexes your current
repository. After indexing, Claude Code can answer questions about code
dependencies through the GitNexus MCP server. You can also browse the knowledge
graph with `gitnexus serve` (opens a web UI).

#### 4.5 Graphify

```bash
pipx install graphifyy
graphify install
```

Installs Graphify via pipx (isolated Python environment). The `graphify install`
command registers a `PreToolUse` hook with Claude Code. After installation, run
`/graphify .` inside a Claude Code session to build the initial graph. Output
appears in the `graphify-out/` directory:

- `graph.html` — Interactive visual dependency map (open in a browser)
- `GRAPH_REPORT.md` — Human-readable report of your codebase structure

#### 4.6 claude-mem (Auto-Pilot Memory)

```bash
npx claude-mem install
```

Registers 5 hooks with Claude Code that automatically:

- Capture session activity (files edited, commands run, tool usage)
- Compress and store session summaries
- Re-inject relevant context at the start of your next session

No configuration needed. After installation, a web viewer is available at
`http://localhost:37777` where you can browse captured session history.

#### 4.7 MemPalace (Knowledge Base)

```bash
pipx install mempalace
mempalace init <project-directory>
claude mcp add mempalace -- python -m mempalace.mcp_server
```

Installs MemPalace via pipx, initializes a "palace" for your project, and
registers it as an MCP server with Claude Code. This gives Claude Code access to
19 MCP tools for searching, adding, and managing your knowledge base.

Key commands you will use:

- `mempalace search "query"` — Find past decisions or knowledge
- `mempalace status` — Check palace occupancy and health
- `mempalace mine ~/chats/ --mode convos` — Extract decisions from conversation
  logs (run weekly)

#### 4.8 Superpowers (Manual Step)

Superpowers is a Claude Code plugin that cannot be installed from a shell script.
You must run this command inside an **interactive Claude Code session**:

```
/plugin install superpowers@claude-plugins-official
```

Then **restart Claude Code**.

After installation, you will have access to these commands:

| Command | Purpose |
|---|---|
| `/superpowers:brainstorm` | Socratic Q&A — explore alternatives before committing to an approach |
| `/superpowers:write-plan` | Generate a step-by-step task list with verification steps |
| `/superpowers:execute-plan` | Execute the plan using RED → GREEN → REFACTOR TDD cycles |
| `/superpowers:code-review` | Review code against the plan, coding standards, and architecture |

You can verify Superpowers is installed by running `/help` inside Claude Code —
the Superpowers commands should appear in the list.

### Post-Installation Verification

After setup completes, run:

```bash
make status
```

This checks each tool and reports its status:

| Check | What It Verifies |
|---|---|
| GitNexus | Repository is indexed and queryable |
| MemPalace | Palace is initialized and accessible |
| OpenSpec | CLI is available, workspace initialized |
| Graphify | Output directory exists (graph has been built) |
| claude-mem | Web viewer is running at localhost:37777 |

If any check fails, review the setup output for warnings about that specific
tool.

### Git Hooks

The setup script configures git to use the `githooks/` directory for hooks:

```bash
git config core.hooksPath githooks/
```

Currently, a **pre-push hook** is installed that automatically runs `make verify`
(spec compliance check) and `make scan` (security scan) before allowing a push.
If either check fails, the push is blocked.

---

## 5. Your First Project — A Walkthrough

This section provides a compact summary of the 10-step workflow. For a detailed,
command-by-command walkthrough with a real feature (JWT refresh token rotation),
see **[2-workflow-guide.md](2-workflow-guide.md) Section 4**.

For structured Day 1 / Week 1 / Month 1 milestones, see
**[4-milestones.md](4-milestones.md)**.

### Standard Flow (Features)

```
Step 1:  Read graphify-out/GRAPH_REPORT.md + mempalace_search
Step 2:  *agent analyst → *workflow-init → Standard
Step 3:  *agent pm (PRD) → *agent architect (arch doc)
Step 4:  /opsx:propose <feature> → /opsx:ff → commit specs
Step 5:  gitnexus_impact on every symbol you'll touch
Step 6:  /superpowers:brainstorm → /superpowers:write-plan
Step 7:  /superpowers:execute-plan (TDD, 1 commit per task)
Step 8:  /superpowers:code-review → make verify → make index → make scan
Step 9:  git push (pre-push hook validates automatically)
Step 10: make archive → make mine (after merge)
```

### Quick Flow (Bug Fixes)

Skip Steps 3–5. Everything else is mandatory.

```
Step 1:  Read graph report + MemPalace search
Step 2:  *agent analyst → *workflow-init → Quick
Step 6:  /superpowers:brainstorm → /superpowers:write-plan
Step 7:  /superpowers:execute-plan
Step 8:  3-layer review (mandatory even for bug fixes)
Step 9:  git push
Step 10: make archive (if specs were involved)
```

### Key Rules

- **Do not modify code on Day 1.** Spend the day understanding the codebase.
- **Each task must have a verification step.** Don't approve vague plans.
- **3-Strike Rule:** If a task fails 3 times, stop and redesign — don't brute-force.
- **Impact > 3 modules → split into smaller PRs.**
- **If Layer 2 fails**, fix the code (not the spec) and re-run.

---

## 6. Daily Operations Reference

### Make Targets

All common operations have Make targets. Run `make help` to see the full list.

| Command | What It Does |
|---|---|
| `make setup` | Install or update all 8 tools (safe to re-run) |
| `make index` | Re-index the codebase in both GitNexus and Graphify |
| `make scan` | Run AgentShield security scan (102 rules) |
| `make scan-deep` | Run AgentShield deep scan (uses Opus model + streaming) |
| `make verify` | Check that your code matches the OpenSpec specs (Layer 2) |
| `make review` | Full 3-layer review coordinator |
| `make archive` | Archive completed specs + re-index (run after merge) |
| `make status` | Show the status of all installed tools |
| `make mine` | Extract decisions from conversations into MemPalace |
| `make clean` | Remove the GitNexus index (asks for confirmation) |

### Superpowers Commands (Inside Claude Code)

| Command | When to Use |
|---|---|
| `/superpowers:brainstorm` | Before starting any implementation — explore alternatives |
| `/superpowers:write-plan` | After brainstorming — generate a task list with verification steps |
| `/superpowers:execute-plan` | After approving the plan — execute with TDD cycles |
| `/superpowers:code-review` | After coding — review against plan, standards, architecture |

### BMAD Agent Commands (Inside Claude Code)

| Command | Which Agent | What It Does |
|---|---|---|
| `*agent analyst` | Analyst | Clarifies scope, asks requirements questions |
| `*agent pm` | PM | Creates PRD with functional/non-functional requirements |
| `*agent architect` | Architect | Creates architecture document |
| `*agent po` | Product Owner | Creates sprint stories from the PRD |
| `*workflow-init` | (meta) | Choose Quick/Standard/Enterprise flow |
| `bmad-help` | (meta) | Shows what step to do next |

### OpenSpec Commands (Inside Claude Code)

| Command | What It Does |
|---|---|
| `/opsx:propose <name>` | Create a new feature proposal |
| `/opsx:ff` | Fast-forward: auto-generate all spec documents |
| `/opsx:apply` | Apply spec changes to code |
| `/opsx:verify` | Check implementation against specs |
| `/opsx:archive` | Archive completed specs |

### When to Re-Index

Run `make index` (which runs `gitnexus analyze` + `graphify . --update`):

- **After every merge** — the knowledge graph must reflect the latest code
- **After significant refactoring** — file moves, renames, module restructuring
- **Before impact analysis** — ensure you are querying up-to-date information

### When to Mine MemPalace

Run `make mine` (which runs `mempalace mine ~/chats/ --mode convos`):

- **Weekly** — as a regular maintenance task
- **After major decisions** — architecture changes, technology choices
- **Before onboarding new team members** — so the knowledge base is current

---

## 7. Common Mistakes

The most critical mistakes to avoid. For tool-specific anti-patterns, see
[2-workflow-guide.md](2-workflow-guide.md) Section 2. For mindset questions, see
[5-faq.md](5-faq.md).

| Don't | Do |
|---|---|
| Code before specs | `/opsx:propose` first — specs are the verification contract |
| Skip brainstorm | `/superpowers:brainstorm` even for "simple" tasks |
| Approve vague plans | Every task needs a verification step |
| Multiple changes per commit | 1 commit per task |
| Push without 3-layer review | `make review` every time |
| Continue after 3 task failures | Stop → redesign → resume |
| PRs > 400 lines | Split by layer, module, or feature flag |
| Dump knowledge into CLAUDE.md | CLAUDE.md = rules. claude-mem = sessions. MemPalace = decisions |
| Skip `make index` after merge | Knowledge graph goes stale → wrong impact analysis |
| Install full ECC plugin | Cherry-pick only (AgentShield + hooks + skills) |
| Bypass hooks with `--no-verify` | Investigate the hook trigger first |

---

## 8. Cost Summary

| Item | Cost |
|---|---|
| Claude Code Pro subscription | $20/month |
| BMAD Method | Free |
| OpenSpec | Free |
| Superpowers | Free |
| ECC (cherry-pick) | Free |
| GitNexus | Free |
| Graphify | Free |
| claude-mem | Free |
| MemPalace | Free |
| **Total** | **$20/month** |

---

## 9. Glossary

| Term | Definition |
|---|---|
| **AST** | Abstract Syntax Tree — a tree representation of your source code's structure. Tools like GitNexus parse the AST to understand how code components relate to each other. |
| **ECC** | Everything Claude Code — a community plugin for Claude Code. VSAF cherry-picks three components from it instead of installing the full plugin. |
| **FR / NFR** | Functional Requirement / Non-Functional Requirement. FRs describe what the system does ("user can log in"). NFRs describe how well it does it ("login responds within 200ms"). |
| **KG** | Knowledge Graph — a database that stores relationships between entities (files, functions, classes, services). GitNexus and Graphify both build knowledge graphs. |
| **MCP** | Model Context Protocol — a standard that lets AI models (like Claude) access external tools and data sources. GitNexus uses MCP to give Claude Code access to the code knowledge graph. |
| **PRD** | Product Requirements Document — a planning document that describes what is being built, for whom, and why. Generated by the BMAD PM agent. |
| **Quick Flow** | A shortened workflow for bug fixes and small changes. Skips Steps 3–5 (planning, specs, impact analysis). |
| **RED → GREEN → REFACTOR** | The TDD cycle: write a failing test (RED), write code to pass it (GREEN), clean up the code (REFACTOR). |
| **TDD** | Test-Driven Development — a practice where you write the test *before* writing the code. Superpowers enforces this during plan execution. |