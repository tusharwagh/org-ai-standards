# OpenSpec project configuration

`openspec/config.yaml` is the project config. `standards-init` lets `openspec init` create it and does not overwrite it on later runs. Edit it in the product repo. This file is the field contract and the writing guide. Upstream: [config.yaml](https://openspec.dev/docs/configuration/config-yaml), [Project configuration](https://openspec.dev/docs/project-config).

## Location

Path: `openspec/config.yaml` at the repository root.

`openspec/config.yml` is read only when `config.yaml` is absent. When both exist, `config.yaml` wins and `config.yml` is ignored. `openspec init` creates `config.yaml`.

Invalid fields do not fail a command. Each field is checked on its own. A bad value is dropped with a warning.

## How a workflow uses it

1. You run a workflow (for example `/openspec-propose` or the apply skill).
2. The agent runs `openspec instructions`.
3. That command reads `context`, `rules`, and `operations` from `config.yaml`.
4. Your text is combined with OpenSpec's built-in instruction and template.
5. The agent writes the artifact from that prompt.

Your config is applied first. Rules are added to the built-in guidance. They do not replace it. The next workflow run picks up edits; nothing else needs a restart.

`verify` does not receive `rules`. It checks the implementation against the artifacts as written.

Keep `context` and `rules` short. They land in the agent prompt on every matching run. Long rules make the output worse.

Put durable project documentation in the repo docs. Put in `context` only constraints the agent cannot learn by reading the code.

## Fields

| Key | Type | Required | Effect |
|-----|------|----------|--------|
| `schema` | string | Yes | Workflow schema for changes in this project |
| `context` | string | No | Injected into every artifact, and into apply and archive |
| `rules` | map of artifact id → list of strings | No | Extra rules for that artifact only |
| `operations` | map of operation → guidance list | No | Advisory guidance for apply and archive |
| `store` | string | No | Fallback OpenSpec root when this `openspec/` is config-only |
| `references` | list | No | Other stores whose spec index is added to instructions |

`schema`, `store`, and `references` choose the schema and which OpenSpec root is used. `context`, `rules`, and `operations` change what the agent is told.

| Field | Injected into |
|-------|----------------|
| `context` | Every artifact, apply, and archive |
| `rules` | Creation of that artifact only |
| `operations` | The named operation only (`apply` or `archive`) |

### schema

Required. `spec-driven` is the default schema `openspec init` writes. Any other value must be a schema name this project defines.

```bash
openspec schemas
```

lists the names the CLI can use. The bootstrapper does not pass `--schema`. New changes follow `schema` in this file.

### context

Free text. Limit 50KB (51,200 bytes UTF-8). A larger value is ignored with a warning.

Use it for constraints that should shape every artifact and both apply and archive. One language for all artifacts is a context line, because context reaches every artifact:

```yaml
context: |
  Designs and tasks must cover Windows, macOS, and Linux
  Write all artifacts in Spanish
```

Leave out stack trivia, folder tours, and anything a read of the repo already shows.

### rules

Extra lines for one artifact, keyed by artifact id. Ids are not limited to the built-in names; custom schemas can use their own ids.

```yaml
rules:
  proposal:
    - Keep proposals under 500 words
    - Always state what is out of scope
  tasks:
    - Break tasks into chunks of max 2 hours
```

Spec-driven artifact ids you will use most often: `proposal`, `specs`, `design`, `tasks`. A rule on `tasks` does not apply to `proposal`.

### operations

Advisory only. How apply and archive work should be carried out, separate from what the artifacts say. Only `apply` and `archive` are read.

```yaml
operations:
  apply:
    guidance:
      - Keep test summaries concise
      - Run the linter before marking a task complete
  archive:
    guidance:
      - Summarize the archive outcome before finishing
```

### store

A store id. Consulted only when this `openspec/` directory is config-only: no `specs/` and no `changes/`. It is a fallback root, not an override. The bootstrapper creates `specs/` and `changes/`, so a normal product repo does not use `store`.

If you later point `store:` at an external store and remove local specs and changes, run `openspec init --tools cursor` from the repository root. Init then writes integration files here and leaves `config.yaml` byte-for-byte. It does not create `specs/` or `changes/` in that mode. `--language` is rejected there; set the language in the store's own config.

### references

Store ids whose specs this project's instructions should index. The index is id, summary, and the command to fetch the spec. Spec body text is not inlined. Root resolution is unchanged.

An entry is a store id, or a map with `id` and an optional `remote` clone URL:

```yaml
references:
  - platform-specs
  - id: billing-specs
    remote: git@github.com:acme/billing-specs.git
```

The bootstrapper does not register stores. Add `references` only after those stores exist on the machine (`openspec store list`).

## Example

```yaml
schema: spec-driven

context: |
  Designs and tasks must cover Windows, macOS, and Linux
  Write all artifacts in Spanish

rules:
  proposal:
    - Keep proposals under 500 words
    - Always state what is out of scope
  tasks:
    - Break tasks into chunks of max 2 hours

operations:
  apply:
    guidance:
      - Keep test summaries concise
  archive:
    guidance:
      - Summarize the archive outcome before finishing
```

`openspec init` writes `schema: spec-driven` and leaves `context`, `rules`, and `operations` commented out with the same examples. Fill in only the lines this repo needs. `standards-init` then appends its own `rules` and `operations` block. That block is separate from the commented examples.

## Standards check

Active changes (everything under `openspec/changes/` except `archive/`) include `standards.md`. One row per id in [standards-catalog.yaml](standards-catalog.yaml) whose profile is listed in `.standards-profiles`:

```markdown
| id | applies | adherence |
|----|---------|-----------|
| ai-sdlc-charter | yes | Autonomy A. Human gate is merge. |
| frontend-ui-engineering | no | This change does not touch UI. |
```

`yes` needs an adherence note. `no` needs a reason. `TODO` and other placeholders fail the check.

`standards-init` marks that block in `openspec/config.yaml` with `# BEGIN org-ai-standards:openspec-rules` and `# END org-ai-standards:openspec-rules`. Re-runs replace only the block. `context` and every other key outside it stay as they are.

```bash
standards/scripts/check-openspec-standards.sh
```

The script reads `.standards-ci-policy`. `fail` exits 1 when a change skips a required id or leaves the note empty. `warn` exits 2. No active changes exits 0. The `openspec-standards` skill is the agent workflow for writing the file and running this command.

## What config cannot change

Config adds instructions on top of the schema. It does not add, remove, or reorder artifacts, and it does not change their templates. When the artifact set itself is wrong, fork a schema (`openspec schema`) instead of stacking more rules.

Global CLI settings (`openspec config`) are per machine, in `$XDG_CONFIG_HOME/openspec/config.json` or `~/.config/openspec/config.json` (Windows: `%APPDATA%\openspec\config.json`). They are not `openspec/config.yaml`. Delivery (skills, commands, or both) and the workflow profile live there. See [INSTALLATION.md](INSTALLATION.md).

## After you edit

No bootstrap re-run is required. The next `openspec instructions`, propose, apply, or archive run reads the file again.

Confirm the CLI still sees this repo as the root:

```bash
openspec context --json
```

`root.path` should be this repository. Installation and init steps are in [INSTALLATION.md](INSTALLATION.md).
