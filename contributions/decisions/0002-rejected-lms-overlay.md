# 0002 — Rejected: LMS-specific FastAPI patterns in generic python skill

**Outcome:** Rejected  
**Issue:** (example — not filed)  
**Source repo:** tusharwagh/LMS-AI  
**Pinned at discovery:** 1.0.1  

## Summary

Proposed adding LMS-AI-specific SQLAlchemy session patterns and import-linter contract names to `clean-code-ddd-python` generic skill.

## Reason for rejection

Content is **product-specific**, not generic delivery standard:

- References LMS bounded contexts (`catalog`, `loan`, `agent`)
- Duplicates material that belongs in `.cursor/skills/lms-ai/clean-code-ddd-lms-ai/`

## Correct action

Contributor should add or extend the **LMS-AI overlay** skill, not upstream to org-ai-standards.

## Verification note (V4.2)

Documents a rejected contribution with reason without blocking product delivery (warn-only CI).
