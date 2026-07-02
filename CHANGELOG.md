# Changelog

All notable template releases use [semver](https://semver.org/).

## Semver policy

| Bump | When | Example |
|------|------|---------|
| **MAJOR** | Removed or renamed managed paths; breaking manifest change | Drop a profile file from manifest |
| **MINOR** | New files, profiles, or backward-compatible standards | Add `standards-init.sh`, neutralize generic layer |
| **PATCH** | Typos, clarifications, non-normative fixes | Wording in a rule |

Product repos pin via `.standards-version` and upgrade with `standards-upgrade` / `make standards-upgrade`.

## [1.1.3] - 2026-07-02

### Changed

- PHASE3-RESULTS: historical note that warn-only was superseded by Phase 5 fail mode

## [1.1.2] - 2026-07-02

### Changed

- GOVERNANCE §3/§7: Phase 5 fail mode documented as complete for LMS-AI; per-repo `CI_POLICY`
- RELEASE.md: CI checklist reflects fail-on-diverged for LMS-AI
- README: latest release v1.1.1

## [1.1.1] - 2026-06-27

### Changed

- Moved specification and rollout plan from LMS-AI to `docs/SPEC.md` and `docs/ROLLOUT.md`
- Updated SPEC-LINK and PLAN-LINK to canonical paths

## [1.1.0] - 2026-06-27

### Added

- Phase 6 scale-out: `bootstrap/standards-init.sh` for new product repos
- `scripts/verify-phase6.sh` — second-repo pilot (`pilot-api` overlay, `core,python` profiles)
- [docs/PHASE6-RESULTS.md](docs/PHASE6-RESULTS.md)

### Changed

- Generic cursor rules/skills: removed hardcoded `lms-ai` overlay paths (V6.2 — template not LMS-shaped)
- Semver policy documented in this CHANGELOG (V6.3)

## [1.0.2] - 2026-06-27

### Added

- Phase 4 contribution loop: GitHub issue template, [CONTRIBUTING.md](CONTRIBUTING.md), `scripts/standards-contribute.sh`
- `contributions/decisions/` accept/reject decision records

### Changed

- `code-simplification` rule: bullet pointing contributors to standard contribution issues (dry-run accepted contribution)

## [1.0.1] - 2026-06-27

### Changed

- Phase 3 pilot patch (LMS-AI submodule integration verification)
- Docs: RELEASE checklist, PHASE3-RESULTS, README (GitHub URL, CI, publish order)

## [1.0.0] - 2026-06-27

### Added

- Initial delivery template extracted from LMS-AI Phase 1 fixture
- Profiles: `core`, `python`, `agentic`, `frontend`
- `manifest.json` with 26 managed paths
- `scripts/check-standards.sh` and `bootstrap/standards-materialize.sh`
- AI-SDLC bootstrap templates under `docs/ai-sdlc/templates/`
- Generic Cursor rules and skills (portable layer)
- [GOVERNANCE.md](GOVERNANCE.md)

### Deferred (Minimal v1)

- `docs/standards/` portable doc extraction
- Org-level profiles
- Fail-mode CI defaults
