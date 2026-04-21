# ASF — Agentic SDLC Framework

A spec-driven development framework. Write specs first, execute with AI, review
in 3 layers. 5-tool stack, $20/month total.

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  SPEC              OpenSpec (propose, verify, archive)               │
├──────────────────────────────────────────────────────────────────────┤
│  CODE INTEL        GitNexus (MCP — impact, context, query)           │
├──────────────────────────────────────────────────────────────────────┤
│  IMPLEMENTATION    Claude Code + Superpowers + AgentShield           │
└──────────────────────────────────────────────────────────────────────┘
```

**Supported platforms:** Claude Code (primary) | GitHub Copilot | Antigravity

## Quickstart

Requires **Node.js ≥ 18**, **Git**, **jq**, and a **Claude Code subscription** ($20/mo).

```bash
git clone <this-repo> && cd agentic-sdlc-framework
make setup          # Install tools (idempotent — safe to re-run)
make status         # Verify everything is working
```

One manual post-setup step (requires an interactive Claude Code session):

```
/plugin install superpowers@claude-plugins-official
```

Restart Claude Code after installing Superpowers.

## Directory Layout

```
.
├── .agent/                  # Antigravity config
├── .claude/
│   └── settings.json        # AgentShield hooks: block secrets, protect config
├── .github/                 # GitHub Copilot config
├── docs/
│   └── superpowers/         # Design specs and implementation plans
├── githooks/                # Git hooks (pre-push security scan)
├── openspec/                # OpenSpec workspace (proposals, tasks, verification)
├── scripts/
│   └── setup-asf.sh         # Setup automation (called by make setup)
├── CLAUDE.md                # Claude Code system prompt — workflow rules
└── Makefile                 # All day-to-day operations
```

## Daily Operations

| Command | What It Does |
|---|---|
| `make setup` | Install or update all tools |
| `make index` | Re-index codebase (GitNexus) — run after every merge |
| `make verify` | Check implementation against OpenSpec specs |
| `make review` | Run 3-layer review |
| `make scan` | Run AgentShield security scan |
| `make status` | Show status of installed tools |

## Tools

| Tool | What It Does | Cost |
|---|---|---|
| **Claude Code** | AI coding agent — primary interface | $20/mo |
| **OpenSpec** | Spec-driven development: proposals, specs, tasks, verification | Free |
| **GitNexus** | Code knowledge graph via MCP — impact analysis, dependency queries | Free |
| **Superpowers** | Methodology engine: brainstorm, plan, TDD execution, code review | Free |
| **AgentShield** | Security scanner + git hooks (block secrets, protect config) | Free |

## Workflow

Every feature follows a **5-step cycle**: spec → impact analysis → brainstorm+plan
→ execute → review+ship.

See `CLAUDE.md` for the full workflow rules and quick-reference command table.

---

**Core principles:** Spec before code. Context is king. 3-layer review before every PR.
