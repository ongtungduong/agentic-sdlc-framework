# ask-ranger — kit development

> You are working on the **ask-ranger kit itself**, not on a target repo that has installed the kit.

## What this repo is

A scaffolding kit. The artifacts users install into their repos live under
[`template/`](template/). The kit's own dev tools live at the root
(`scripts/`, `tests/`, `.github/workflows/`, `Makefile`, `package.json`).

## Where the rules are

- [CONTRIBUTING.md](CONTRIBUTING.md) — how to propose changes, run tests, ship PRs.
- [template/CLAUDE.md](template/CLAUDE.md) — the workflow the kit teaches. Kit development follows it too; this file is the layout pointer, that one is the discipline.
- [CHANGELOG.md](CHANGELOG.md) — release history.

## Pre-commit sanity (kit development)

```bash
bats tests/                    # all 28 tests pass, no network required
bash scripts/sync-platforms.sh # must leave the tree clean (CI enforces drift)
shellcheck scripts/setup.sh scripts/sync-platforms.sh \
  scripts/session-end-check.sh scripts/hooks/gitleaks-precheck.sh \
  template/githooks/pre-push
```

## Canonical source vs generated

Canonical opsx workflow source: [`template/workflows/<skill>/SKILL.md`](template/workflows/).
Generated copies (do not edit): `template/.claude/`, `template/.agent/`, `template/.github/{prompts,skills}/`.

Edit canonical, then `bash scripts/sync-platforms.sh`.

<!-- gitnexus:start -->
<!-- gitnexus:end -->
