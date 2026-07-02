# Phase 6 results — scale-out

**Date:** 2026-06-27  
**Release:** v1.1.0  
**Status:** Complete

## Goal

Validate the template is not LMS-shaped; bootstrap a second product profile.

## Deliverables

| # | Deliverable | Location |
|---|-------------|----------|
| 6.1 | `standards init` | `bootstrap/standards-init.sh` |
| 6.2 | Non-LMS overlay name | Pilot uses `pilot-api` (not `lms-ai`) |
| 6.3 | Profile subset | Pilot uses `core,python` (no agentic/frontend) |
| 6.4 | Org profiles | Deferred to v1.1 |
| 6.5 | `docs/standards/` extraction | Deferred |

## Pilot (dry-run workspace)

```bash
./scripts/verify-phase6.sh
```

Creates `bootstrap/pilot-workspace/` (gitignored):

```text
pilot-workspace/
├── standards/              ← copy of template @ VERSION
├── .standards-version
├── .standards-profiles     ← core,python
├── .cursor/rules/pilot-api/   ← overlay (not lms-ai)
├── .cursor/rules/generic/     ← materialized subset
└── docs/ai-sdlc/CHARTER.md    ← instantiated
```

## Verification

| ID | Check | Result |
|----|-------|--------|
| V6.1 | Second repo check-standards clean after init | Pass |
| V6.2 | No LMS-AI paths in generic canonical layer | Pass |
| V6.3 | CHANGELOG semver policy | Pass |

## Bootstrap a real second repo

```bash
git submodule add https://github.com/tusharwagh/org-ai-standards.git standards
cd standards && git checkout v1.1.0 && cd ..
./standards/bootstrap/standards-init.sh --overlay my-app --profiles core,python
```

## Generic layer cleanup (V6.2)

Removed hardcoded `lms-ai` overlay links from `cursor/rules/generic/` and `cursor/skills/generic/`. Project overlays are referenced generically as `.cursor/rules/<project>/`.

`manifest.json` `never_compare` no longer lists `lms-ai/**` — overlays are excluded because they are not manifest entries.

## Consumers

- **LMS-AI** remains on v1.0.2 until maintainers run `make standards-upgrade VERSION=1.1.0` (MINOR — review generic copy changes).
- **New repos** should start at v1.1.0+.
