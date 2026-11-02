#!/usr/bin/env bash
# Install the OpenSpec CLI if needed, init the project for Cursor, and copy guidelines.
# Called from standards-init.sh. Run from the product repository root.
set -euo pipefail

ROOT="${STANDARDS_ROOT:-$(pwd)}"
cd "$ROOT"
REFERENCE="${STANDARDS_REFERENCE:-standards}"
TOOLS="${OPENSPEC_TOOLS:-cursor}"
DOCS_SRC="$REFERENCE/docs/openspec"

if [[ ! -f "$DOCS_SRC/INSTALLATION.md" || ! -f "$DOCS_SRC/CONFIGURATION.md" || ! -f "$DOCS_SRC/standards-catalog.yaml" ]]; then
  echo "OpenSpec guidelines missing under $DOCS_SRC" >&2
  echo "Expected INSTALLATION.md, CONFIGURATION.md, and standards-catalog.yaml" >&2
  exit 1
fi

mkdir -p docs/openspec
cp -f "$DOCS_SRC/INSTALLATION.md" "$DOCS_SRC/CONFIGURATION.md" "$DOCS_SRC/standards-catalog.yaml" docs/openspec/
echo "copied docs/openspec/INSTALLATION.md"
echo "copied docs/openspec/CONFIGURATION.md"
echo "copied docs/openspec/standards-catalog.yaml"

if [[ -z "$TOOLS" ]]; then
  echo "OPENSPEC_TOOLS is empty. Use cursor, a comma-separated tool list, all, or none." >&2
  exit 1
fi

prepend_install_dir() {
  local dir="${OPENSPEC_INSTALL_DIR:-$HOME/.local/bin}"
  case ":$PATH:" in
    *":$dir:"*) ;;
    *) PATH="$dir:$PATH" ;;
  esac
  export PATH
  hash -r 2>/dev/null || true
}

install_standalone() {
  local uname_s
  uname_s="$(uname -s)"
  case "$uname_s" in
    Darwin | Linux)
      echo "openspec CLI not on PATH; installing standalone binary"
      curl -fsSL https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/scripts/binary/install.sh | sh
      prepend_install_dir
      ;;
    MINGW* | MSYS* | CYGWIN*)
      echo "OpenSpec auto-install supports macOS and Linux." >&2
      echo "On Windows, run the PowerShell installer in docs/openspec/INSTALLATION.md, then re-run standards-init." >&2
      exit 1
      ;;
    *)
      echo "OpenSpec auto-install supports macOS and Linux (uname=$uname_s)." >&2
      echo "Install the CLI using docs/openspec/INSTALLATION.md, then re-run standards-init." >&2
      exit 1
      ;;
  esac
}

if ! command -v openspec >/dev/null 2>&1; then
  install_standalone
fi

if ! command -v openspec >/dev/null 2>&1; then
  echo "openspec is still not on PATH after install." >&2
  echo "Add the directory the installer printed, then re-run standards-init." >&2
  echo "Steps: docs/openspec/INSTALLATION.md" >&2
  exit 1
fi

echo "openspec $(openspec --version)"
openspec init --tools "$TOOLS" --no-animation --force

python3 - <<'PY'
from pathlib import Path

path = Path("openspec/config.yaml")
begin = "# BEGIN org-ai-standards:openspec-rules"
end = "# END org-ai-standards:openspec-rules"
block = """# BEGIN org-ai-standards:openspec-rules
rules:
  proposal:
    - Write standards.md covering every enabled id in docs/openspec/standards-catalog.yaml. Run standards/scripts/check-openspec-standards.sh before finishing the proposal.
  design:
    - Write standards.md covering every enabled id in docs/openspec/standards-catalog.yaml. Run standards/scripts/check-openspec-standards.sh before finishing the design.
  tasks:
    - Write standards.md covering every enabled id in docs/openspec/standards-catalog.yaml. Each task that applies a standard names that standard id. Run standards/scripts/check-openspec-standards.sh before finishing the tasks.
operations:
  apply:
    guidance:
      - Re-run standards/scripts/check-openspec-standards.sh before marking tasks complete.
  archive:
    guidance:
      - Do not archive while standards/scripts/check-openspec-standards.sh fails under the fail policy.
# END org-ai-standards:openspec-rules
"""
text = path.read_text(encoding="utf-8") if path.is_file() else "schema: spec-driven\n"
start = text.find(begin)
stop = text.find(end)
if start != -1 and stop != -1 and stop >= start:
    stop_end = stop + len(end)
    if stop_end < len(text) and text[stop_end] == "\n":
        stop_end += 1
    text = text[:start] + block + "\n" + text[stop_end:]
else:
    if text and not text.endswith("\n"):
        text += "\n"
    if not text.endswith("\n\n"):
        text += "\n"
    text += block + "\n"
path.parent.mkdir(parents=True, exist_ok=True)
path.write_text(text, encoding="utf-8")
print("merged openspec/config.yaml standards rules")
PY

echo "OpenSpec ready (tools=$TOOLS). Edit openspec/config.yaml using docs/openspec/CONFIGURATION.md"
echo "Active changes need openspec/changes/<name>/standards.md. Check with standards/scripts/check-openspec-standards.sh."
echo "Restart Cursor so the new skills and commands load."
