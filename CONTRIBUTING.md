# Contributing to org-ai-standards

Generic delivery standards (Cursor rules, skills, AI-SDLC templates) live here. Product-specific material stays in each product repo overlay (e.g. LMS-AI `.cursor/rules/lms-ai/`).

## When to contribute

| Situation | Action |
|-----------|--------|
| Generic rule/skill/template improvement | **Standard contribution** (this doc) |
| Product-only convention | Product repo overlay — **not** upstream |
| Emergency local fix on managed copy | Revert or upstream ASAP; do not leave diverged |

## Contribution loop

```text
Product: make check-standards  →  diverged / contribution_candidate
              │
              ▼
Product: make standards-contribute [--open]  →  issue body from drift report
              │
              ▼
Template owner: triage (accept / reject)
              │
       accept ▼                    reject ▼
  PR + semver tag            close issue + decision note
              │
              ▼
Product: make standards-upgrade VERSION=X.Y.Z
```

Governance detail: [GOVERNANCE.md §6](GOVERNANCE.md#6-contribution-loop-g5).

## Open an issue

1. **[Standard contribution](https://github.com/tusharwagh/org-ai-standards/issues/new?template=standard-contribution.yml)** — preferred for drift-driven improvements.
2. Or open a **PR** directly if you already have a ready patch (link the issue if one exists).

Label: `contribution`.

## From a product repo (LMS-AI)

```bash
git submodule update --init standards
make check-standards              # shows diverged paths
make standards-contribute         # prints issue body
make standards-contribute OPEN=1   # opens GitHub issue (requires gh auth)
```

## Template owner triage

| Outcome | Actions |
|---------|---------|
| **Accept** | Merge PR → update `VERSION`, `CHANGELOG.md` → tag → `git push origin main --tags` → record in [contributions/decisions/](contributions/decisions/) |
| **Reject** | Close issue with reason → record in [contributions/decisions/](contributions/decisions/) |

Decision notes are numbered markdown files: `contributions/decisions/NNNN-slug.md`.

## Semver

| Bump | When |
|------|------|
| PATCH | Clarifications, typos, non-breaking rule text |
| MINOR | New files, profiles, backward-compatible standards |
| MAJOR | Removed/renamed managed paths; breaking manifest |

See [docs/RELEASE.md](docs/RELEASE.md) for publish order (push tags **before** product submodule bump).

## What not to contribute (v1)

- Org architecture / technology / business standards (deferred to v1.1 profiles)
- Product CHARTER content
- Secrets or environment-specific config
