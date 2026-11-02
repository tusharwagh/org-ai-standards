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

log "=== V6.1 OpenSpec bootstrap ==="
OPENSPEC_DOCS_INSTALL="$PILOT/docs/openspec/INSTALLATION.md"
OPENSPEC_DOCS_CONFIG="$PILOT/docs/openspec/CONFIGURATION.md"
OPENSPEC_CONFIG="$PILOT/openspec/config.yaml"
OPENSPEC_SKILL="$PILOT/.cursor/skills/openspec-propose/SKILL.md"
OPENSPEC_CMD="$PILOT/.cursor/commands/opsx-propose.md"
if [[ -f "$OPENSPEC_DOCS_INSTALL" ]] && [[ -f "$OPENSPEC_DOCS_CONFIG" ]] \
  && [[ -f "$OPENSPEC_CONFIG" ]] && [[ -f "$OPENSPEC_SKILL" ]] && [[ -f "$OPENSPEC_CMD" ]] \
  && grep -q "schema: spec-driven" "$OPENSPEC_CONFIG" \
  && grep -q "org-ai-standards:openspec-rules" "$OPENSPEC_CONFIG" \
  && [[ -f "$PILOT/docs/openspec/standards-catalog.yaml" ]]; then
  pass "V6.1 OpenSpec CLI init, config, and guidelines"
else
  fail "V6.1 OpenSpec bootstrap"
  ls -la "$PILOT/docs/openspec" "$PILOT/openspec" "$PILOT/.cursor/skills" "$PILOT/.cursor/commands" 2>/dev/null || true
fi

log "=== V6.1 OpenSpec standards.md ==="
CHANGE="$PILOT/openspec/changes/fixture-adherence"
rm -rf "$CHANGE"
mkdir -p "$CHANGE"
if STANDARDS_ROOT="$PILOT" "$PILOT/standards/scripts/check-openspec-standards.sh" >/tmp/v6-os-missing.json; then
  fail "V6.1 missing standards.md should be a finding"
  cat /tmp/v6-os-missing.json
else
  if python3 -c 'import json; r=json.load(open("/tmp/v6-os-missing.json")); assert r["findings"], r; assert any(f.get("type")=="missing_file" for f in r["findings"]), r'; then
    pass "V6.1 missing standards.md is a finding"
  else
    fail "V6.1 missing standards.md report"
    cat /tmp/v6-os-missing.json
  fi
fi

cat > "$CHANGE/standards.md" <<'EOF'
| id | applies | adherence |
|----|---------|-----------|
| ai-sdlc-charter | yes | Autonomy A. Human gate is merge. |
| ai-sdlc-change-log | yes | Stage implement. Intent is the fixture change. |
| code-simplification | yes | No new branching. Keep the fixture to one file. |
| doubt-driven-development | no | Mechanical fixture with no non-trivial decision. |
| security-and-hardening | no | No untrusted input, auth, or storage. |
| api-and-interface-design | no | No public interface change. |
| sonarqube-quality | no | No application code in the fixture. |
| clean-code-ddd-python | no | No domain or module code in the fixture. |
| python-code-analysis | yes | Checker command is the verification for this fixture. |
EOF

if STANDARDS_ROOT="$PILOT" "$PILOT/standards/scripts/check-openspec-standards.sh" >/tmp/v6-os-ok.json; then
  if python3 -c 'import json; r=json.load(open("/tmp/v6-os-ok.json")); assert r["status"]=="clean" and r["findings"]==[], r'; then
    pass "V6.1 complete standards.md is clean"
  else
    fail "V6.1 complete standards.md report"
    cat /tmp/v6-os-ok.json
  fi
else
  fail "V6.1 complete standards.md should pass"
  cat /tmp/v6-os-ok.json
fi
rm -rf "$CHANGE"

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
