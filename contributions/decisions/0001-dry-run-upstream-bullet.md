# 0001 — Dry-run: upstream bullet in code-simplification

**Outcome:** Accepted  
**Issue:** (dry-run — Phase 4 verification; file issue via `make standards-contribute` in LMS-AI)  
**PR:** merged to `main` as part of Phase 4 deliverables  
**Release:** v1.0.2  
**Source repo:** tusharwagh/LMS-AI  
**Pinned at discovery:** 1.0.1  

## Summary

Add a "When NOT to use" bullet directing engineers to open a standard contribution issue instead of leaving diverged edits on managed generic copies in product repos.

## Affected paths

- `cursor/rules/generic/code-simplification.md`
- `.cursor/rules/generic/code-simplification.md` (materialized)

## Rationale

Closes the loop between `check-standards` → `contribution_candidate` and the GitHub issue template introduced in Phase 4.

## Product follow-up

LMS-AI: `make standards-upgrade VERSION=1.0.2` → `make check-standards` clean.
