#!/usr/bin/env bash
# Phase 4 verification (contribution loop).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FAIL=0

log() { printf '%s\n' "$*"; }
pass() { log "PASS  $1"; }
fail() { log "FAIL  $1"; FAIL=1; }

log "=== V4.1 issue template ==="
if [[ -f .github/ISSUE_TEMPLATE/standard-contribution.yml ]]; then
  pass "V4.1 issue template present"
else
  fail "V4.1"
fi

log "=== V4.1 contribute script ==="
if [[ -x scripts/standards-contribute.sh ]]; then
  pass "V4.1 standards-contribute.sh"
else
  fail "V4.1 script"
fi

log "=== V4.1 decisions dir ==="
if [[ -f contributions/decisions/0001-dry-run-upstream-bullet.md ]]; then
  pass "V4.1 accepted decision record"
else
  fail "V4.1 decisions"
fi

log "=== V4.2 rejected decision ==="
if [[ -f contributions/decisions/0002-rejected-lms-overlay.md ]]; then
  pass "V4.2 rejected example documented"
else
  fail "V4.2"
fi

log "=== V4.3 self-check clean @ VERSION ==="
if ./bootstrap/verify-template.sh >/tmp/verify-phase4.out 2>&1; then
  pass "V4.3 template self-check"
else
  fail "V4.3 self-check"
  cat /tmp/verify-phase4.out
fi

exit "$FAIL"
