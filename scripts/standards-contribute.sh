#!/usr/bin/env bash
# Build a standard-contribution issue body from check-standards drift report.
set -euo pipefail

ROOT="${STANDARDS_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

REFERENCE="${STANDARDS_REFERENCE:-standards}"
MANIFEST="${STANDARDS_MANIFEST:-standards/manifest.json}"
VERSION_FILE="${STANDARDS_VERSION_FILE:-.standards-version}"
LATEST_FILE="${STANDARDS_LATEST_FILE:-.standards-latest}"
PROFILES_FILE="${STANDARDS_PROFILES_FILE:-.standards-profiles}"
OPEN="${OPEN:-0}"
REPO="${STANDARDS_CONTRIBUTE_REPO:-tusharwagh/org-ai-standards}"
SOURCE_REPO="${STANDARDS_SOURCE_REPO:-}"

if [[ -z "$SOURCE_REPO" ]]; then
  ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
  SOURCE_REPO="$(printf '%s' "$ORIGIN" | sed -E 's#.*github.com[:/]([^/]+/[^/.]+)(\.git)?$#\1#' || true)"
  SOURCE_REPO="${SOURCE_REPO:-unknown/unknown}"
fi

REPORT="$(mktemp)"
META="$(mktemp)"
trap 'rm -f "$REPORT" "$META"' EXIT

CHECK="${ROOT}/${REFERENCE}/scripts/check-standards.sh"
[[ -x "$CHECK" ]] || CHECK="${ROOT}/scripts/check-standards.sh"
chmod +x "$CHECK"

export STANDARDS_ROOT="$ROOT" STANDARDS_REFERENCE="$REFERENCE" STANDARDS_MANIFEST="$MANIFEST"
export STANDARDS_VERSION_FILE="$VERSION_FILE" STANDARDS_LATEST_FILE="$LATEST_FILE"
export STANDARDS_PROFILES_FILE="$PROFILES_FILE" STANDARDS_REPORT="$REPORT" CI_POLICY=warn

"$CHECK" >/dev/null 2>&1 || true

if [[ ! -s "$REPORT" ]]; then
  echo "No drift report produced. Run from a product repo with standards/ submodule." >&2
  exit 1
fi

python3 - "$REPORT" "$SOURCE_REPO" "$META" <<'PY'
import json
import sys
from pathlib import Path

report = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
source = sys.argv[2]
meta_path = Path(sys.argv[3])
pinned = report.get("standards_version", "?")
diverged = [f for f in report.get("findings", []) if f.get("type") == "diverged"]

if not diverged:
    body = "\n".join([
        "## No contribution candidates",
        "",
        f"check-standards status: **{report.get('status', 'unknown')}**",
        "",
        "No diverged managed paths. Edit a generic managed copy locally to simulate a candidate,",
        "or open a standard contribution issue manually for a proposed upstream change.",
    ])
    meta_path.write_text(json.dumps({"body": body, "title": "", "has_candidates": False}), encoding="utf-8")
    sys.exit(0)

first = diverged[0]["path"].split("/")[-1].replace(".md", "").replace("-", " ")
title = f"contrib: {first} improvement from {source}"
paths = "\n".join(f"- `{f['path']}` (ref: `{f.get('reference', '?')}`)" for f in diverged)
body = "\n".join([
    "## Summary",
    "",
    f"Generic improvement discovered in `{source}` @ standards `{pinned}`.",
    "",
    "## Affected managed paths",
    "",
    paths,
    "",
    "## Proposed change",
    "",
    "<!-- Describe the improvement and paste draft text or diff -->",
    "",
    "## Drift report",
    "",
    "```json",
    json.dumps(report, indent=2),
    "```",
])
meta_path.write_text(json.dumps({"body": body, "title": title, "has_candidates": True}), encoding="utf-8")
PY

BODY="$(python3 -c 'import json; print(json.load(open("'"$META"'"))["body"])')"
HAS="$(python3 -c 'import json; print(json.load(open("'"$META"'"))["has_candidates"])')"

if [[ "$HAS" == "False" ]]; then
  echo "$BODY"
  exit 0
fi

TITLE="$(python3 -c 'import json; print(json.load(open("'"$META"'"))["title"])')"

if [[ "$OPEN" == "1" ]]; then
  if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI not found. Install GitHub CLI or run without OPEN=1." >&2
    echo "$BODY"
    exit 1
  fi
  gh issue create --repo "$REPO" --title "$TITLE" --label contribution --body "$BODY"
  echo "Issue created on ${REPO}"
else
  echo "$BODY"
  echo ""
  echo "---"
  echo "Open: https://github.com/${REPO}/issues/new?template=standard-contribution.yml"
  echo "Or:   make standards-contribute OPEN=1"
fi
