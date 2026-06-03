#!/usr/bin/env bash
# PreToolUse(Bash) guard for agentic-lab (public repo).
#
# Blocks `git commit` / `git push` that would leak secrets or stage sensitive
# paths (TEMP/, .dev/, .env, keys, *secret*/*token*/*credentials*).
#
# Hook contract (Claude Code):
#   exit 2 -> BLOCK the tool call; stderr is shown to Claude as the reason.
#   exit 0 -> allow.
# Secrets gate is FAIL-CLOSED: if gitleaks is missing, commit/push is blocked.
#
# Limitation: this only fires when Claude runs git. A human running git in a
# terminal bypasses it. The .pre-commit-config.yaml hooks and CI cover that.
set -uo pipefail

payload="$(cat)"
cmd="$(printf '%s' "$payload" \
  | python3 -c 'import sys, json; print(json.load(sys.stdin).get("tool_input", {}).get("command", ""))' \
  2>/dev/null || true)"

# Act only on git commit / git push; allow everything else.
case "$cmd" in
  *"git commit"*|*"git push"*) : ;;
  *) exit 0 ;;
esac

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
cd "$repo_root" || exit 0

block() { printf 'BLOCKED by pre-git-guard: %s\n' "$1" >&2; exit 2; }

# --- Path guard: refuse sensitive paths in the staged set ---
staged="$(git diff --cached --name-only 2>/dev/null || true)"
if [ -n "$staged" ]; then
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    base="$(basename "$f")"
    case "$f" in
      TEMP/*|.dev/*) block "sensitive path staged: $f" ;;
    esac
    case "$base" in
      *.pem|*.key|*.p12|id_rsa|id_rsa.*) block "key material staged: $f" ;;
      .env.example|*.env.example) : ;;
      .env|.env.*|*.env) block "env file staged: $f" ;;
      *secret*|*token*|*credentials*) block "sensitive-named file staged: $f" ;;
    esac
  done <<< "$staged"
fi

# --- Content guard: gitleaks (fail-closed) ---
if ! command -v gitleaks >/dev/null 2>&1; then
  block "gitleaks not found; refusing to commit/push blind. Install: brew install gitleaks"
fi

case "$cmd" in
  *"git commit"*)
    if ! gitleaks protect --staged --redact --no-banner >/dev/null 2>&1; then
      block "gitleaks found a secret in staged changes. Unstage it, or move it to .env (gitignored)."
    fi
    ;;
  *"git push"*)
    if ! gitleaks detect --redact --no-banner >/dev/null 2>&1; then
      block "gitleaks found a secret in repo history. Do not push; rewrite history to remove it first."
    fi
    ;;
esac

exit 0
