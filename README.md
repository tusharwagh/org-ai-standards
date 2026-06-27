# org-ai-standards

Delivery template for AI-assisted repositories — generic Cursor rules/skills, AI-SDLC bootstrap assets, profiles, and drift checking.

**Release:** v1.0.0 (semver tag `v1.0.0`)  
**Governance:** [GOVERNANCE.md](GOVERNANCE.md)

## Profiles

| Profile | Purpose |
|---------|---------|
| `core` | AI-SDLC templates, traceability assets, core rules (required) |
| `python` | Python / FastAPI engineering rules and skills |
| `agentic` | LLM / agent governance skill |
| `frontend` | Frontend UI engineering rule |

Example: `core,python,agentic,frontend`

## Product repo bootstrap (Phase 3+)

```bash
# Add submodule @ tag
git submodule add -b v1.0.0 <REPO_URL> standards
git submodule update --init --recursive

# Pin and profiles (copy examples to repo root)
cp standards/.standards-version.example .standards-version
cp standards/.standards-latest.example .standards-latest
cp standards/.standards-profiles.example .standards-profiles

# Materialize managed copies into .cursor/
standards/bootstrap/standards-materialize.sh

# Drift check
standards/scripts/check-standards.sh
```

## Template repo self-check

```bash
cp .standards-version.example .standards-version
cp .standards-latest.example .standards-latest
cp .standards-profiles.example .standards-profiles
./bootstrap/verify-template.sh
```

## Layout

```text
cursor/rules/generic/       # canonical Cursor rules
cursor/skills/generic/      # canonical skills
docs/ai-sdlc/templates/   # AI-SDLC bootstrap templates
profiles/                   # profile indexes
manifest.json               # managed paths
scripts/                    # check-standards, build-manifest
bootstrap/                  # materialize, verify
```

See LMS-AI [template-standards-plan.md](https://github.com/) for rollout phases.
