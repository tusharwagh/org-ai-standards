#!/usr/bin/env bash
# Initialize org-ai-standards in a product repository (Phase 6 scale-out).
# Run from product repo root after standards/ exists (submodule or copy).
set -euo pipefail

OVERLAY="${STANDARDS_OVERLAY:-app}"
PROFILES="${STANDARDS_PROFILES:-core,python}"
CI_POLICY="${STANDARDS_CI_POLICY:-warn}"
INIT_VERSION="${STANDARDS_INIT_VERSION:-}"

usage() {
  cat <<'EOF'
Usage: standards-init.sh [OPTIONS]

Run from product repository root (standards/ must exist).

Options:
  --overlay NAME    Project overlay folder under .cursor/rules|skills/ (default: app)
  --profiles LIST   Comma-separated profiles (default: core,python)
  --version VER     Pin version (default: standards/VERSION)
  --ci-policy POL   warn | fail (default: warn)
  -h, --help        Show this help

Environment: STANDARDS_ROOT, STANDARDS_REFERENCE (default: standards)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --overlay)
      OVERLAY="$2"
      shift 2
      ;;
    --profiles)
      PROFILES="$2"
      shift 2
      ;;
    --version)
      INIT_VERSION="$2"
      shift 2
      ;;
    --ci-policy)
      CI_POLICY="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

ROOT="${STANDARDS_ROOT:-$(pwd)}"
cd "$ROOT"
REFERENCE="${STANDARDS_REFERENCE:-standards}"

if [[ ! -d "$REFERENCE" ]]; then
  echo "standards/ missing at $ROOT/$REFERENCE" >&2
  echo "Add submodule: git submodule add https://github.com/tusharwagh/org-ai-standards.git standards" >&2
  exit 1
fi

if [[ -z "$INIT_VERSION" ]]; then
  INIT_VERSION="$(tr -d '[:space:]' < "$REFERENCE/VERSION")"
fi
LATEST="${STANDARDS_LATEST:-$INIT_VERSION}"

printf '%s\n' "$INIT_VERSION" > .standards-version
printf '%s\n' "$LATEST" > .standards-latest
printf '%s\n' "$PROFILES" > .standards-profiles
printf '%s\n' "$CI_POLICY" > .standards-ci-policy

mkdir -p ".cursor/rules/$OVERLAY" ".cursor/skills/$OVERLAY" docs/ai-sdlc

cat > ".cursor/rules/$OVERLAY/README.md" <<EOF
# Project overlay (\`$OVERLAY\`)

Repo-specific rule addenda. Not drift-checked by \`check-standards\`.

Pair with generic rules under \`.cursor/rules/generic/\` per [org-ai-standards](https://github.com/tusharwagh/org-ai-standards).
EOF

cat > ".cursor/skills/$OVERLAY/README.md" <<EOF
# Project skills overlay (\`$OVERLAY\`)

Repo-specific skill addenda. Not drift-checked by \`check-standards\`.
EOF

if [[ ! -f docs/ai-sdlc/CHARTER.md ]]; then
  cp "$REFERENCE/docs/ai-sdlc/templates/CHARTER.template.md" docs/ai-sdlc/CHARTER.md
  sed -i.bak "s/PROJECT/$OVERLAY/g" docs/ai-sdlc/CHARTER.md 2>/dev/null || \
    sed -i '' "s/PROJECT/$OVERLAY/g" docs/ai-sdlc/CHARTER.md
  rm -f docs/ai-sdlc/CHARTER.md.bak
fi

if [[ ! -f docs/ai-sdlc/CHANGELOG.md ]]; then
  cp "$REFERENCE/docs/ai-sdlc/templates/CHANGELOG.template.md" docs/ai-sdlc/CHANGELOG.md
fi

if [[ ! -f .cursor/README.md ]]; then
  cat > .cursor/README.md <<EOF
# Cursor guidance

| Path | Role |
|------|------|
| \`.cursor/rules/generic/\` | Managed copies from \`standards/\` — do not edit in place |
| \`.cursor/rules/$OVERLAY/\` | Project overlay |
| \`.cursor/skills/generic/\` | Managed copies |
| \`.cursor/skills/$OVERLAY/\` | Project overlay |

Ops: \`make check-standards\` (if Makefile wired) or \`standards/scripts/check-standards.sh\`.
EOF
fi

MATERIALIZE="$REFERENCE/bootstrap/standards-materialize.sh"
CHECK="$REFERENCE/scripts/check-standards.sh"
chmod +x "$MATERIALIZE" "$CHECK"

export STANDARDS_ROOT="$ROOT" STANDARDS_REFERENCE="$REFERENCE" \
  STANDARDS_MANIFEST="$REFERENCE/manifest.json" STANDARDS_PROFILES_FILE=.standards-profiles
"$MATERIALIZE"

export STANDARDS_VERSION_FILE=.standards-version STANDARDS_LATEST_FILE=.standards-latest \
  CI_POLICY="$CI_POLICY"
"$CHECK"

echo "standards-init complete: overlay=$OVERLAY profiles=$PROFILES version=$INIT_VERSION"
