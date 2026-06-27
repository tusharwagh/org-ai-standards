#!/usr/bin/env bash
# V2.1–V2.5 checks for Phase 2 exit criteria.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
FAIL=0

log() { printf '%s\n' "$*"; }
pass() { log "PASS  $1"; }
fail() { log "FAIL  $1"; FAIL=1; }

log "=== V2.1 self-check ==="
if ./bootstrap/verify-template.sh; then pass "V2.1"; else fail "V2.1"; fi

log "=== V2.2 tag / manifest ==="
ENTRIES=$(python3 -c "import json; print(len(json.load(open('manifest.json'))['entries']))")
if [[ "$ENTRIES" -ge 26 ]]; then pass "V2.2 manifest ($ENTRIES entries)"; else fail "V2.2"; fi

log "=== V2.3 file count ==="
COUNT=$(find cursor docs/ai-sdlc/templates profiles -type f | wc -l | tr -d ' ')
if [[ "$COUNT" -ge 26 ]]; then pass "V2.3 canonical files ($COUNT)"; else fail "V2.3"; fi

log "=== V2.4 domain spot-check ==="
if grep -r "K-12 library management monolith" cursor/ docs/ai-sdlc/templates/*.template.md 2>/dev/null; then
  fail "V2.4 LMS domain text in generic/template paths"
else
  pass "V2.4 no LMS domain in generic paths"
fi

log "=== V2.5 shellcheck ==="
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck scripts/*.sh bootstrap/*.sh; then pass "V2.5 shellcheck"; else fail "V2.5"; fi
else
  pass "V2.5 shellcheck skipped (not installed)"
fi

exit "$FAIL"
