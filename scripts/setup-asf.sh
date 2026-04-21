#!/usr/bin/env bash
# setup-asf.sh — ASF — Agentic SDLC Framework setup
# Installs and configures: OpenSpec, GitNexus, AgentShield (ECC hooks), Superpowers (manual).
# Idempotent. Ubuntu 24 / macOS supported.
set -euo pipefail

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[FAIL]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }
step()  { echo -e "\n${CYAN}==> $*${NC}"; }

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# ---------------------------------------------------------------------------
# Auto-install missing prerequisites (jq)
# ---------------------------------------------------------------------------
auto_install_prereqs() {
    step "Auto-installing missing prerequisites"
    local OS
    OS=$(detect_os)

    if ! command -v jq &>/dev/null; then
        info "jq not found — attempting auto-install..."
        case "$OS" in
            linux)
                sudo apt install -y jq &>/dev/null \
                    && ok "jq auto-installed (apt)" \
                    || err "Failed to auto-install jq. Install manually: sudo apt install jq"
                ;;
            macos)
                brew install jq &>/dev/null \
                    && ok "jq auto-installed (brew)" \
                    || err "Failed to auto-install jq. Install manually: brew install jq"
                ;;
            *)
                err "Unknown OS — install jq manually: https://jqlang.github.io/jq/"
                ;;
        esac
    else
        ok "No auto-install needed — all installable prerequisites present"
    fi
}

# ---------------------------------------------------------------------------
# Prerequisite checks
# ---------------------------------------------------------------------------
check_prereqs() {
    step "Checking prerequisites"
    local failed=0

    # Node >= 18
    if command -v node &>/dev/null; then
        NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
        if [ "$NODE_VER" -ge 18 ]; then
            ok "Node.js v$(node -v | sed 's/v//')"
        else
            err "Node.js $(node -v) found — v18+ required. Install: https://nodejs.org/"
            failed=1
        fi
    else
        err "Node.js not found — v18+ required. Install: https://nodejs.org/"
        failed=1
    fi

    if command -v npm &>/dev/null; then
        ok "npm $(npm -v)"
    else
        err "npm not found — install Node.js (includes npm): https://nodejs.org/"
        failed=1
    fi

    if command -v git &>/dev/null; then
        ok "git $(git --version | awk '{print $3}')"
    else
        err "git not found — install: sudo apt install git (Ubuntu) or xcode-select --install (macOS)"
        failed=1
    fi

    if command -v jq &>/dev/null; then
        ok "jq $(jq --version 2>&1 | sed 's/jq-//')"
    else
        err "jq not found — required for AgentShield hook merging. Install: sudo apt install jq (Ubuntu) or brew install jq (macOS)"
        failed=1
    fi

    if [ "$failed" -ne 0 ]; then
        fail "Missing prerequisites. Install them and re-run."
    fi
    ok "All prerequisites satisfied"
}

# ---------------------------------------------------------------------------
# Tool installation helper
# ---------------------------------------------------------------------------
npm_global_install() {
    local pkg="$1"
    local cmd="${2:-$pkg}"
    if command -v "$cmd" &>/dev/null; then
        ok "$cmd already installed"
    else
        info "Installing $pkg..."
        npm install -g "$pkg"
        ok "$cmd installed"
    fi
}

# ---------------------------------------------------------------------------
# 1. OpenSpec
# ---------------------------------------------------------------------------
install_openspec() {
    step "Installing OpenSpec"
    npm_global_install "@fission-ai/openspec@latest" "openspec"
    if [ -f "openspec/config.yaml" ] || [ -f "openspec.json" ]; then
        ok "OpenSpec already initialized"
    else
        openspec init
        ok "OpenSpec initialized"
    fi
}

# ---------------------------------------------------------------------------
# 2. GitNexus
# ---------------------------------------------------------------------------
install_gitnexus() {
    step "Installing GitNexus"
    npm_global_install "gitnexus" "gitnexus"
    info "Running gitnexus setup..."
    gitnexus setup 2>/dev/null || true
    info "Indexing repository..."
    gitnexus analyze . 2>/dev/null || warn "gitnexus analyze failed — run manually after setup"
    ok "GitNexus configured"
}

# ---------------------------------------------------------------------------
# 3. AgentShield (ECC cherry-pick — hooks only)
# ---------------------------------------------------------------------------
install_agentshield() {
    step "Installing AgentShield (ECC hooks)"

    local ECC_DIR="/tmp/ecc"
    local CLAUDE_HOME="${HOME}/.claude"

    if [ ! -d "$ECC_DIR" ]; then
        info "Cloning ECC repository..."
        git clone --depth 1 https://github.com/anthropics/ecc.git "$ECC_DIR" 2>/dev/null \
            || git clone --depth 1 https://github.com/affaan-m/everything-claude-code.git "$ECC_DIR"
    fi

    mkdir -p "$CLAUDE_HOME"
    local TARGET="$CLAUDE_HOME/settings.json"
    [ ! -f "$TARGET" ] && echo '{}' > "$TARGET"

    if [ -f "$ECC_DIR/hooks/hooks.json" ]; then
        info "Merging AgentShield hooks into $TARGET (non-destructive)..."
        local MERGED
        MERGED=$(jq -s '
            .[0] as $existing |
            .[1] as $ecc |
            $existing * {
                hooks: {
                    PreToolUse:  (($existing.hooks.PreToolUse // []) + ($ecc.hooks.PreToolUse // []) | unique_by(.description)),
                    PostToolUse: (($existing.hooks.PostToolUse // []) + ($ecc.hooks.PostToolUse // []) | unique_by(.description))
                }
            }
        ' "$TARGET" "$ECC_DIR/hooks/hooks.json" 2>/dev/null) || true
        if [ -n "$MERGED" ]; then
            echo "$MERGED" > "$TARGET"
            ok "Hooks merged into $TARGET"
        else
            warn "Could not merge hooks — manual merge may be needed"
        fi
    else
        warn "ECC hooks/hooks.json not found — skipping hook merge"
    fi

    rm -rf "$ECC_DIR"
    ok "AgentShield installed (temp clone removed)"
}

# ---------------------------------------------------------------------------
# 4. Superpowers (manual — requires Claude Code interactive session)
# ---------------------------------------------------------------------------
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

# ---------------------------------------------------------------------------
# Git hooks configuration
# ---------------------------------------------------------------------------
configure_git_hooks() {
    step "Configuring git hooks"
    mkdir -p githooks
    git config core.hooksPath githooks/
    ok "Git hooks path set to githooks/"
}

# ---------------------------------------------------------------------------
# Verification
# ---------------------------------------------------------------------------
verify_install() {
    step "Verifying installation"
    local pass=0
    local total=0

    verify_cmd() {
        total=$((total + 1))
        if eval "$1" &>/dev/null; then
            ok "$2"
            pass=$((pass + 1))
        else
            warn "$2 — FAILED"
        fi
    }

    verify_cmd "command -v openspec"                   "OpenSpec available"
    verify_cmd "gitnexus status"                       "GitNexus indexed"
    verify_cmd "npx ecc-agentshield --version"         "AgentShield available"
    verify_cmd "test -f ${HOME}/.claude/settings.json" "Global Claude hooks configured"
    verify_cmd "test -f .claude/settings.json"         "Local Claude hooks configured"

    echo ""
    info "Verification: $pass/$total checks passed"
    if [ "$pass" -lt "$total" ]; then
        warn "Some tools need manual attention. See warnings above."
    else
        ok "All verifications passed"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "============================================================"
    echo "  ASF — Agentic SDLC Framework Setup"
    echo "  Spec-driven development | 3-layer review | 5 tools"
    echo "============================================================"
    echo ""

    auto_install_prereqs
    check_prereqs

    install_openspec
    install_gitnexus
    install_agentshield
    print_superpowers_instructions
    configure_git_hooks

    verify_install

    echo ""
    echo "============================================================"
    echo "  Setup complete. Next steps:"
    echo "  1. Install Superpowers in Claude Code (see instructions above)"
    echo "  2. Run:  make status   (verify all tools)"
    echo "  3. Read: CLAUDE.md     (system prompt / workflow rules)"
    echo "============================================================"
    echo ""
}

main "$@"
