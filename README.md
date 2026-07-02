# org-ai-standards

Delivery template for AI-assisted repositories — generic Cursor rules/skills, AI-SDLC bootstrap assets, profiles, and drift checking.

**Repository:** https://github.com/tusharwagh/org-ai-standards  
**Latest release:** v1.1.1 (tag `v1.1.1`)  
**Governance:** [GOVERNANCE.md](GOVERNANCE.md) · **Contributing:** [CONTRIBUTING.md](CONTRIBUTING.md)

## Profiles

| Profile | Purpose |
|---------|---------|
| `core` | AI-SDLC templates, traceability assets, core rules (**required**) |
| `python` | Python / FastAPI engineering rules and skills |
| `agentic` | LLM / agent governance skill |
| `frontend` | Frontend UI engineering rule |

Example: `core,python,agentic,frontend`

## Product repo integration (LMS-AI pilot)

[LMS-AI](https://github.com/tusharwagh/LMS-AI) consumes this repo as a **git submodule** at `standards/`:

```text
LMS-AI/
├── standards/              ← submodule → this repo @ pinned commit/tag
├── .standards-version      ← e.g. 1.0.1
├── .standards-latest       ← latest template release (for stale checks)
├── .standards-profiles     ← e.g. core,python,agentic,frontend
├── .standards-copied-at    ← audit trail after materialize/upgrade
├── .cursor/rules/generic/  ← copies (managed — do not edit in place)
└── .cursor/rules/lms-ai/   ← project overlay (never drift-checked)
```

LMS-AI commands: `make check-standards`, `make standards-materialize`, `make standards-upgrade`, `make standards-contribute`.

See [docs/PHASE3-RESULTS.md](docs/PHASE3-RESULTS.md) for pilot verification and CI notes.

## Bootstrap a new product repo

```bash
git submodule add https://github.com/tusharwagh/org-ai-standards.git standards
cd standards && git checkout v1.1.0 && cd ..

./standards/bootstrap/standards-init.sh --overlay my-app --profiles core,python
```

`standards-init` writes pin files, creates overlay dirs, instantiates `docs/ai-sdlc/`, materializes enabled profiles, and runs `check-standards`.

**Profile subset example:** `core,python` omits agentic and frontend assets. **Overlay name** is your project (not `lms-ai`).

### Manual bootstrap (alternative)

**CI:** Use an **HTTPS submodule URL** in `.gitmodules` (not a relative path). Checkout with `submodules: recursive`. See [docs/RELEASE.md](docs/RELEASE.md).

## Template repo self-check

```bash
cp .standards-version.example .standards-version
cp .standards-latest.example .standards-latest
cp .standards-profiles.example .standards-profiles
./bootstrap/verify-template.sh
```

## Release a new version

1. Merge changes to `main`
2. Update `VERSION` and `CHANGELOG.md`
3. Tag semver: `git tag -a vX.Y.Z -m "..."`
4. **Push before any product repo bumps the submodule pointer:**

```bash
git push origin main --tags
```

5. Product repos: `make standards-upgrade VERSION=X.Y.Z` (or equivalent) and commit the new submodule SHA.

Full checklist: [docs/RELEASE.md](docs/RELEASE.md)

## Layout

```text
cursor/rules/generic/         # canonical Cursor rules
cursor/skills/generic/        # canonical skills
docs/ai-sdlc/templates/       # AI-SDLC bootstrap templates
profiles/                     # profile indexes
manifest.json                 # managed paths (26 entries @ v1.0.1)
scripts/                      # check-standards, build-manifest, verify-phase2
bootstrap/                    # materialize, verify-template, standards-init
GOVERNANCE.md                 # ownership, change flow, contributions
```

## Related docs

| Doc | Purpose |
|-----|---------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution loop, issue template, `standards-contribute` |
| [GOVERNANCE.md](GOVERNANCE.md) | Roles, change authority, upgrade, contributions |
| [docs/RELEASE.md](docs/RELEASE.md) | Publish tags + product-repo bump order |
| [docs/PHASE6-RESULTS.md](docs/PHASE6-RESULTS.md) | Scale-out pilot + standards-init |
| [docs/PHASE4-RESULTS.md](docs/PHASE4-RESULTS.md) | Contribution loop verification |
| [docs/PHASE3-RESULTS.md](docs/PHASE3-RESULTS.md) | LMS-AI pilot + CI submodule fix |
| [docs/SPEC.md](docs/SPEC.md) | Full specification |
| [docs/ROLLOUT.md](docs/ROLLOUT.md) | Phased rollout (complete) |

Spec and plan: [docs/SPEC.md](SPEC.md), [docs/ROLLOUT.md](ROLLOUT.md).
