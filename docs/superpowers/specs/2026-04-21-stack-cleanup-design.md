# Stack Cleanup Design — 5-Tool Stack

**Date:** 2026-04-21
**Status:** Approved

## Goal

Reduce ASF from an 8-tool stack to a focused 5-tool stack. Remove all tools that add complexity without clear value at the $20/mo tier. Keep only what is portable, vendor-neutral, and actively used.

## Target Stack

```
┌─────────────────────────────────────────────────────┐
│  Spec layer          OpenSpec                        │
├─────────────────────────────────────────────────────┤
│  Code intelligence   GitNexus (MCP)                  │
├─────────────────────────────────────────────────────┤
│  Implementation      Claude Code (primary)           │
│                      Superpowers                     │
│                      AgentShield (standalone CLI)    │
└─────────────────────────────────────────────────────┘
```

**Supported platforms:** Claude Code (primary) | GitHub Copilot | Antigravity

## Tools Removed

| Tool | Reason |
|---|---|
| BMAD | Heavyweight planning agents replaced by Superpowers brainstorm+plan |
| Graphify | Multimodal KG adds setup complexity; GitNexus MCP covers code intelligence |
| claude-mem | Auto-session memory adds hooks overhead; not essential for workflow |
| MemPalace | Knowledge base overkill for single-repo workflows |

## Platforms Removed

| Platform | Reason |
|---|---|
| Cursor | Not in supported platform list |
| Codex | Not in supported platform list |

## Files to Delete

| Path | Type |
|---|---|
| `_bmad/` | BMAD agents, config, manifests |
| `mempalace.yaml` | MemPalace project config |
| `entities.json` | MemPalace entity file |
| `docs/onboarding/` | Onboarding docs referencing removed tools |
| `.cursor/` | Cursor platform config |
| `.codex/` | Codex platform config |

## Files to Rewrite

### CLAUDE.md
Complete rewrite. New structure:
- Identity: 3-layer stack (OpenSpec / GitNexus / Claude Code+Superpowers+AgentShield)
- Supported platforms: Claude Code, GitHub Copilot, Antigravity
- 5-step workflow (see below)
- Quick reference table (5 tools only)
- Commit discipline (unchanged)
- Security (AgentShield only)
- Anti-patterns (remove BMAD/Graphify/claude-mem/MemPalace rows)
- GitNexus MCP instructions (kept in full)

### New 5-Step Workflow

```
Step 1: Spec
  /opsx:propose <feature>
  git commit -m "spec: ..."

Step 2: Impact Analysis
  gitnexus_impact(target, "upstream")
  gitnexus_context(name)
  Impact > 3 modules → split PRs

Step 3: Brainstorm + Plan
  /superpowers:brainstorm
  /superpowers:write-plan

Step 4: Execute
  /superpowers:execute-plan  (RED → GREEN → REFACTOR)
  1 commit per task. Fail 3x → architectural review.

Step 5: Review + Ship
  /superpowers:code-review
  /opsx:verify
  npx ecc-agentshield scan
  git push && /opsx:archive
```

### README.md
- Update architecture diagram to 5-tool stack
- Update quickstart (remove `make index` graphify step, remove MemPalace/claude-mem)
- Update directory layout (remove `_bmad/`, `graphify-out/`)
- Remove all sections referencing removed tools

### AGENTS.md
- Keep GitNexus section in full (it is the MCP backbone)
- Remove any references to BMAD, MemPalace, Graphify, claude-mem

### Makefile
- Remove `mine` target (MemPalace mining)
- `index` target: remove graphify step, keep `gitnexus analyze` only
- `status` target: remove Graphify, MemPalace, claude-mem sections
- `review` target: remove graphify from Layer 3
- `setup` description: update to reflect 5-tool stack

### scripts/setup-asf.sh
Rewrite to install only:
1. OpenSpec (`npm install -g @fission-ai/openspec@latest`)
2. GitNexus (`npm install -g gitnexus`)
3. AgentShield (ECC cherry-pick — AgentShield + hooks only, no language skills)
4. Superpowers (manual step — requires Claude Code interactive session)

Remove: BMAD install, Graphify install, claude-mem install, MemPalace install.

## Files to Keep Unchanged

| Path | Reason |
|---|---|
| `openspec/` | Active spec workspace |
| `githooks/` | Git hooks (pre-push) |
| `.claude/settings.json` | ECC hooks (block secrets, protect config) |
| `.github/` | GitHub Copilot config |
| `.agent/` | Antigravity config |

## Approach

Single commit: delete all excess files and rewrite all affected files atomically. No intermediate broken state.
