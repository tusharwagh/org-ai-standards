# Phase 3 — LMS-AI pilot results

**Consumer:** [LMS-AI](https://github.com/tusharwagh/LMS-AI)  
**Template pin:** v1.0.1 (`adb35c5` on `main`)  
**Run:** 2026-06-27

## Integration summary

| Item | Value |
|------|-------|
| Submodule path | `standards/` |
| Submodule URL | `https://github.com/tusharwagh/org-ai-standards.git` |
| Profiles | `core,python,agentic,frontend` |
| Managed paths | 26 (see `manifest.json`) |
| CI drift policy | warn-only (non-blocking) |

## CI submodule fix (2026-06-27)

**Symptom:** GitHub Actions failed checkout with `not our ref adb35c5…`.

**Cause:** LMS-AI’s submodule pointer referenced commit `adb35c5` (v1.0.1) that existed only locally. Remote `main` was still at `a13757e` (v1.0.0); tags were not pushed.

**Fix:**

1. `git push origin main --tags` from `org-ai-standards`
2. `.gitmodules` URL changed from relative `../org-ai-standards` to HTTPS GitHub URL
3. `git submodule sync` in LMS-AI

**Rule for all future releases:** see [RELEASE.md](RELEASE.md) — push template, then bump consumer.

## Verification (from LMS-AI)

| ID | Check | Result |
|----|-------|--------|
| V3.1 | `make check-standards` clean | PASS |
| V3.2 | Diverged generic → warn | PASS |
| V3.3 | Overlay ignored | PASS |
| V3.4 | CHARTER not in manifest | PASS |
| V3.5 | Upgrade 1.0.0 → 1.0.1 | PASS |
| V3.6 | Cursor paths present | PASS |

LMS-AI detail: `docs/template-standards/PHASE3-RESULTS.md` in the LMS-AI repo.

## Next

Phase 4 — contribution loop (GitHub issues on this repo).
