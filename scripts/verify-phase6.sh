#!/usr/bin/env bash
# Phase 6 verification — second-repo pilot (scale-out).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FAIL=0
PILOT="$ROOT/bootstrap/pilot-workspace"
OVERLAY="pilot-api"
PROFILES="core,python"

log() { printf '%s\n' "$*"; }
pass() { log "PASS  $1"; }
fail() { log "FAIL  $1"; FAIL=1; }

log "=== V6.0 prepare pilot workspace ==="
rm -rf "$PILOT"
mkdir -p "$PILOT/standards"
rsync -a \
  --exclude .git \
  --exclude bootstrap/pilot-workspace \
  "$ROOT/" "$PILOT/standards/"

log "=== V6.1 standards-init (overlay=$OVERLAY profiles=$PROFILES) ==="
if (
  cd "$PILOT"
  chmod +x standards/bootstrap/standards-init.sh
  STANDARDS_ROOT="$PILOT" STANDARDS_REFERENCE=standards \
    ./standards/bootstrap/standards-init.sh --overlay "$OVERLAY" --profiles "$PROFILES"
) >/tmp/v6-init.out 2>&1; then
  pass "V6.1 init + check-standards clean"
else
  fail "V6.1 init"
  cat /tmp/v6-init.out
fi

log "=== V6.1 profile subset materialized ==="
AGENTIC="$PILOT/.cursor/skills/generic/imda-agentic-ai-governance/SKILL.md"
FRONTEND="$PILOT/.cursor/rules/generic/frontend-ui-engineering.md"
PYTHON="$PILOT/.cursor/skills/generic/clean-code-ddd-python/SKILL.md"
if [[ ! -f "$AGENTIC" ]] && [[ ! -f "$FRONTEND" ]] && [[ -f "$PYTHON" ]]; then
  pass "V6.1 core,python only (no agentic/frontend)"
else
  fail "V6.1 profile subset"
  ls -la "$PILOT/.cursor/skills/generic/" 2>/dev/null || true
fi

log "=== V6.2 no lms-ai overlay required ==="
if [[ -d "$PILOT/.cursor/rules/$OVERLAY" ]] && [[ ! -d "$PILOT/.cursor/rules/lms-ai" ]]; then
  pass "V6.2 overlay is $OVERLAY not lms-ai"
else
  fail "V6.2 overlay name"
fi

if ! grep -rq "lms-ai" "$PILOT/standards/cursor" 2>/dev/null; then
  pass "V6.2 no lms-ai paths in generic canonical layer"
else
  fail "V6.2 lms-ai refs in standards/cursor"
  grep -rn "lms-ai" "$PILOT/standards/cursor" | head -5
fi

log "=== V6.2 generic layer spot-check ==="
if grep -rq "K-12 library management monolith" "$PILOT/standards/cursor" 2>/dev/null; then
  fail "V6.2 LMS domain text in generic"
else
  pass "V6.2 no LMS domain in generic"
fi

log "=== V6.3 CHANGELOG semver policy ==="
if grep -qi "semver" "$ROOT/CHANGELOG.md" && grep -q "MAJOR" "$ROOT/CHANGELOG.md"; then
  pass "V6.3 CHANGELOG documents semver"
else
  fail "V6.3 semver in CHANGELOG"
fi

exit "$FAIL"
