# Release and publish checklist

Use this whenever cutting a new template version that product repos (e.g. LMS-AI) will pin.

## Order matters

Product CI clones the submodule from **GitHub**. If LMS-AI (or any consumer) records submodule commit `abc123` before that commit exists on the remote, CI fails with:

```text
fatal: remote error: upload-pack: not our ref abc123
Fetched in submodule path 'standards', but it did not contain abc123
```

**Always push this repo first, then bump the consumer.**

## Checklist

### 1. Template repo (`org-ai-standards`)

- [ ] Changes merged to `main`
- [ ] `VERSION` updated (e.g. `1.0.2`)
- [ ] `CHANGELOG.md` entry added
- [ ] `python3 scripts/build-manifest.py` if profiles/paths changed
- [ ] `./bootstrap/verify-template.sh` passes
- [ ] Annotated tag: `git tag -a vX.Y.Z -m "org-ai-standards vX.Y.Z"`
- [ ] **Push:** `git push origin main --tags`

Verify remote:

```bash
git ls-remote origin refs/heads/main 'refs/tags/vX.Y.Z'
```

### 2. Product repo (LMS-AI)

- [ ] `.gitmodules` uses HTTPS: `https://github.com/tusharwagh/org-ai-standards.git`
- [ ] `make standards-upgrade VERSION=X.Y.Z` (or checkout tag in `standards/` and re-materialize)
- [ ] `make check-standards` → clean
- [ ] Commit: submodule pointer, `.standards-version`, `.standards-copied-at`, materialized copies if changed
- [ ] Append `docs/ai-sdlc/CHANGELOG.md`
- [ ] Push LMS-AI

### 3. CI

- [ ] Consumer workflow uses `actions/checkout` with `submodules: recursive`
- [ ] Drift step is warn-only until Phase 5 (LMS-AI: `continue-on-error: true`)

## Semver (reminder)

| Bump | When |
|------|------|
| MAJOR | Breaking manifest path removal or rename |
| MINOR | New managed files, profiles, backward-compatible standards |
| PATCH | Typos, clarifications, non-normative fixes |

## Tags on GitHub

Tags must be pushed explicitly. `git push origin main` alone does **not** publish tags unless you use `--tags` or `git push origin vX.Y.Z`.
