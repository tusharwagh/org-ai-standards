#!/usr/bin/env bash
# Check active OpenSpec changes record adherence to enabled profile standards.
set -euo pipefail

ROOT="${STANDARDS_ROOT:-$(pwd)}"
cd "$ROOT"

PROFILES_FILE="${STANDARDS_PROFILES_FILE:-.standards-profiles}"
CATALOG="${OPENSPEC_STANDARDS_CATALOG:-docs/openspec/standards-catalog.yaml}"
POLICY_FILE="${STANDARDS_CI_POLICY_FILE:-.standards-ci-policy}"

export ROOT PROFILES_FILE CATALOG POLICY_FILE
export CI_POLICY="${CI_POLICY:-}"

python3 - <<'PY'
import json
import os
import sys
from pathlib import Path

root = Path(os.environ["ROOT"])
profiles_file = root / os.environ["PROFILES_FILE"]
catalog_path = root / os.environ["CATALOG"]
policy_file = root / os.environ["POLICY_FILE"]

placeholders = {
    "todo",
    "tbd",
    "fixme",
    "placeholder",
    "template placeholder",
    "...",
    "<note>",
    "<reason>",
}


def load_profiles() -> list[str]:
    if not profiles_file.is_file():
        return []
    text = profiles_file.read_text(encoding="utf-8")
    return [part.strip() for part in text.split(",") if part.strip()]


def load_policy() -> str:
    if policy_file.is_file():
        value = policy_file.read_text(encoding="utf-8").strip()
        if value:
            return value
    return os.environ.get("CI_POLICY") or "warn"


def load_catalog() -> list[dict]:
    if not catalog_path.is_file():
        return []
    entries: list[dict] = []
    current: dict | None = None
    for raw in catalog_path.read_text(encoding="utf-8").splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        if line.startswith("  - id:"):
            if current:
                entries.append(current)
            current = {"id": line.split(":", 1)[1].strip()}
            continue
        if current is None:
            continue
        if line.startswith("    profile:"):
            current["profile"] = line.split(":", 1)[1].strip()
        elif line.startswith("    obligation:"):
            current["obligation"] = line.split(":", 1)[1].strip()
    if current:
        entries.append(current)
    return entries


def parse_rows(text: str) -> dict[str, tuple[str, str]]:
    found: dict[str, tuple[str, str]] = {}
    for raw in text.splitlines():
        line = raw.strip()
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        if len(cells) < 3:
            continue
        standard_id, applies, note = cells[0], cells[1].lower(), cells[2]
        if not standard_id or standard_id.lower() in {"id", "standard"}:
            continue
        if set(standard_id) <= set("-: "):
            continue
        found[standard_id] = (applies, note.strip())
    return found


def is_placeholder(note: str) -> bool:
    return note.strip().lower() in placeholders


def emit(status: str, policy: str, profiles: list[str], findings: list[dict]) -> None:
    report = {
        "status": status,
        "ci_policy": policy,
        "profiles": profiles,
        "findings": findings,
    }
    print(json.dumps(report, indent=2))
    if status == "clean":
        sys.exit(0)
    if status == "fail":
        sys.exit(1)
    sys.exit(2)


profiles = load_profiles()
policy = load_policy()
findings: list[dict] = []

if not profiles_file.is_file():
    findings.append(
        {
            "type": "missing_profiles",
            "message": f"Missing {profiles_file.name}",
        }
    )
elif not catalog_path.is_file():
    findings.append(
        {
            "type": "missing_catalog",
            "message": f"Missing {catalog_path.as_posix()}",
        }
    )
else:
    enabled = set(profiles)
    required = [
        entry
        for entry in load_catalog()
        if entry.get("profile") in enabled and entry.get("id")
    ]
    changes = root / "openspec" / "changes"
    active = []
    if changes.is_dir():
        active = [
            path
            for path in sorted(changes.iterdir())
            if path.is_dir() and path.name != "archive" and not path.name.startswith(".")
        ]
    for change in active:
        standards = change / "standards.md"
        if not standards.is_file():
            findings.append(
                {
                    "change": change.name,
                    "type": "missing_file",
                    "message": f"{change.name}/standards.md is missing",
                }
            )
            continue
        rows = parse_rows(standards.read_text(encoding="utf-8"))
        for entry in required:
            standard_id = entry["id"]
            if standard_id not in rows:
                findings.append(
                    {
                        "change": change.name,
                        "type": "missing_id",
                        "id": standard_id,
                        "message": f"{change.name} is missing {standard_id}",
                    }
                )
                continue
            applies, note = rows[standard_id]
            if applies == "yes":
                if not note:
                    kind = "empty_note"
                    message = f"{change.name} {standard_id} has an empty adherence note"
                elif is_placeholder(note):
                    kind = "placeholder"
                    message = f"{change.name} {standard_id} adherence note is a placeholder"
                else:
                    continue
            elif applies == "no":
                if not note or is_placeholder(note):
                    kind = "missing_reason"
                    message = f"{change.name} {standard_id} applies=no needs a reason"
                else:
                    continue
            else:
                kind = "bad_applies"
                message = f"{change.name} {standard_id} applies must be yes or no"
            findings.append(
                {
                    "change": change.name,
                    "type": kind,
                    "id": standard_id,
                    "message": message,
                }
            )

if not findings:
    emit("clean", policy, profiles, findings)
elif policy == "fail":
    emit("fail", policy, profiles, findings)
else:
    emit("warn", policy, profiles, findings)
PY
