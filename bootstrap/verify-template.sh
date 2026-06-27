#!/usr/bin/env bash
# Phase 2 verification: materialize + check-standards in template repo (V2.1).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cp -f .standards-version.example .standards-version
cp -f .standards-latest.example .standards-latest
cp -f .standards-profiles.example .standards-profiles

chmod +x bootstrap/standards-materialize.sh scripts/check-standards.sh
STANDARDS_ROOT="$ROOT" STANDARDS_REFERENCE="." ./bootstrap/standards-materialize.sh

if STANDARDS_ROOT="$ROOT" STANDARDS_REFERENCE="." ./scripts/check-standards.sh | python3 -c '
import json, sys
r = json.load(sys.stdin)
assert r["status"] == "clean", r
print("verify-template: clean")
'; then
  exit 0
fi
exit 1
