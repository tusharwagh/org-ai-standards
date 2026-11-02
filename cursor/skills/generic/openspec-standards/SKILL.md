---
name: openspec-standards
description: Records how an OpenSpec change follows the enabled org rules and skills. Use when proposing, updating, applying, or archiving an OpenSpec change, or when the user says openspec propose, opsx propose, openspec apply, or openspec archive.
---

# OpenSpec standards adherence

Every active change under `openspec/changes/` (everything except `archive/`) carries `standards.md`. The file answers each standard enabled by `.standards-profiles`. The rule and skill texts stay in `.cursor/`; this file only records how the change follows them.

## When to use

- Starting or revising a proposal, design, or task list
- Applying tasks
- Archiving a change

## Workflow

1. Read `.standards-profiles` and `docs/openspec/standards-catalog.yaml`.
2. Keep catalog rows whose `profile` is enabled. Ignore the rest.
3. Read the materialized rule or skill for each enabled id under `.cursor/rules/generic/` or `.cursor/skills/generic/`. Use that file as the constraint. Do not copy it into the change.
4. Write `openspec/changes/<name>/standards.md`:

```markdown
| id | applies | adherence |
|----|---------|-----------|
| ai-sdlc-charter | yes | Autonomy A. Human gate is merge. |
| code-simplification | no | Docs-only change; no code paths. |
```

- `applies` is `yes` or `no`.
- `yes` needs an adherence note that answers the catalog `obligation`. `TODO`, `TBD`, `FIXME`, and other placeholders do not count.
- `no` needs a reason.
- A task that applies a standard names that standard id in `tasks.md`.

5. Run:

```bash
standards/scripts/check-openspec-standards.sh
```

Finish the proposal, design, tasks, apply, or archive only when the report is clean, or when `.standards-ci-policy` is `warn` and the findings are reported to the user. When the policy is `fail`, stop while findings remain. Do not archive a change the checker rejects under `fail`.
