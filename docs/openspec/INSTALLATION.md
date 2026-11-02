# OpenSpec installation

`standards-init` installs the OpenSpec CLI when it is missing, then runs project init. These are the same steps, for a machine or a re-run by hand.

The CLI is once per machine. Project files (`openspec/` and the Cursor skills and commands) are once per repo. Upstream: [Installation](https://openspec.dev/docs/installation), [Set up your project](https://openspec.dev/docs/setup).

## What the bootstrapper does

From the product repo root, `standards/bootstrap/standards-init.sh` calls `standards/bootstrap/openspec-setup.sh`, which:

1. Copies this file, [CONFIGURATION.md](CONFIGURATION.md), and [standards-catalog.yaml](standards-catalog.yaml) to `docs/openspec/`.
2. Installs the standalone `openspec` binary when `openspec` is not on `PATH` (macOS and Linux).
3. Runs:

```bash
openspec init --tools cursor --no-animation --force
```

4. Merges the standards `rules` and `operations` block into `openspec/config.yaml`, then `standards-init` runs `standards/scripts/check-openspec-standards.sh`. With no active changes, that check is clean.

`--tools` skips the interactive picker. `--force` removes leftovers from older OpenSpec layouts without a prompt. Re-running init is safe: tools already set up are refreshed, and an existing `openspec/config.yaml` is kept.

Override the tool list with `OPENSPEC_TOOLS` (comma-separated ids, `all`, or `none`). Default is `cursor`.

```bash
OPENSPEC_TOOLS=cursor,claude ./standards/bootstrap/standards-init.sh --overlay my-app --profiles core,python
```

Restart Cursor after init so the new commands load.

## Check the CLI

```bash
openspec --version
```

A version number means the CLI is on `PATH`.

## Standalone install (default)

OpenSpec ships as one `openspec` file. It does not need Node.js. The bootstrapper uses this method.

macOS or Linux:

```bash
curl -fsSL https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/scripts/binary/install.sh | sh
```

Windows (PowerShell). The bootstrap script does not run this; Git Bash on Windows is not auto-installed:

```powershell
irm https://raw.githubusercontent.com/Fission-AI/OpenSpec/main/scripts/binary/install.ps1 | iex
```

- Install path: `~/.local/bin` on macOS and Linux. On Windows, `%LOCALAPPDATA%\Programs\openspec`, which the installer adds to the user PATH.
- The installer selects the file for this machine and checks it against the release `SHA256SUMS`.
- It installs the newest release whose files are all attached. In the short window after a release is published, it installs the previous release and says so.
- Alpine Linux: `apk add libstdc++ libgcc` before the installer.
- `OPENSPEC_INSTALL_DIR` chooses another directory. `OPENSPEC_VERSION=v1.15.0` pins a release (example pin; use the version you intend).

If the installer says the directory is not on `PATH`, add the directory it prints. Do not edit shell startup files from the bootstrap script; fix `PATH` in the shell you use, then run `openspec --version`.

`openspec-setup.sh` prepends `${OPENSPEC_INSTALL_DIR:-$HOME/.local/bin}` for the rest of that run so init can see a binary that was just installed.

### Download a binary yourself

Each release has one file per platform:

| Platform | File |
|----------|------|
| macOS 13+ (Apple silicon / Intel) | `openspec-darwin-arm64` / `openspec-darwin-x64` |
| Linux, glibc 2.17+ (arm64 / x64) | `openspec-linux-arm64` / `openspec-linux-x64` |
| Alpine 3.17+ (arm64 / x64) | `openspec-linux-arm64-musl` / `openspec-linux-x64-musl` |
| Windows 10+ (arm64 / x64) | `openspec-windows-arm64.exe` / `openspec-windows-x64.exe` |

Rename the file to `openspec` (`openspec.exe` on Windows), `chmod +x openspec` on macOS or Linux, and place it on `PATH`.

A browser download on macOS stays quarantined until:

```bash
xattr -d com.apple.quarantine openspec
```

The install script above does not need that.

Optional check with the GitHub CLI (the installer already verifies `SHA256SUMS`):

```bash
gh attestation verify openspec-darwin-arm64 --repo Fission-AI/OpenSpec
```

Use the file name you downloaded.

## Package managers

These install the npm package and need Node.js 20.19.0 or newer. Homebrew and Nix bring their own Node. The bootstrapper does not use these unless you install the CLI yourself before `standards-init`.

```bash
node --version
```

If that is `v20.19.0` or higher:

```bash
npm install -g @fission-ai/openspec@latest
```

Otherwise install a newer Node (nodejs.org, nvm, fnm, asdf, or volta) or use the standalone install.

### Homebrew

```bash
brew install openspec
```

The formula is in homebrew-core. No tap.

### Yarn

`yarn global add` is Yarn Classic (1.x) only. Current Yarn has no global install. Use npm, pnpm, or bun for the CLI. The global CLI does not have to match the project's package manager.

### pnpm

```bash
pnpm add -g @fission-ai/openspec@latest
```

Requires Node.js 20.19.0 or newer, same as npm.

### Bun

Bun can install the package. It does not run it. Node must still be on the machine, or every command fails with `env: node: No such file or directory`.

### Deno

```bash
deno install --global \
  --allow-read --allow-write --allow-env --allow-sys=cpus,homedir --allow-net=edge.openspec.dev \
  npm:@fission-ai/openspec@latest
```

`openspec config edit` launches an editor. Deno asks for permission on every launch unless you add a scoped `--allow-run=` for that program.

If `@latest` does not resolve, pin a range: `npm:@fission-ai/openspec@^1.7.0`.

### Nix

```bash
nix profile install github:Fission-AI/OpenSpec
```

One-off, nothing left on `PATH`:

```bash
nix run github:Fission-AI/OpenSpec -- --version
```

For a project dev shell, add the flake as an input and use its default package. The Nix package includes Bash, Fish, and Zsh completions, so `openspec completion install` is unnecessary there.

## Project init

With the CLI on `PATH`, from the repository root:

```bash
cd <your-project>
openspec init --tools cursor
```

Init writes:

- `openspec/` at the repo root
- Cursor workflow files under `.cursor/skills/` and `.cursor/commands/`

Commit those paths with the rest of the repo. Init does not change other project files. If it finds an older OpenSpec layout, it asks before deleting those leftovers unless you pass `--force` (the bootstrapper does).

Default layout:

```text
openspec/
├── config.yaml          # schema, context, rules, operations
├── specs/               # current specs (empty until the first archive/sync)
└── changes/             # in-progress changes
    └── archive/         # finished changes
```

Cursor files from the default profile (OpenSpec 1.15):

```text
.cursor/skills/
├── openspec-explore/
├── openspec-propose/
├── openspec-apply-change/
├── openspec-update-change/
├── openspec-sync-specs/
└── openspec-archive-change/
.cursor/commands/
├── opsx-explore.md
├── opsx-propose.md
├── opsx-apply.md
├── opsx-update.md
├── opsx-sync.md
└── opsx-archive.md
```

Skills are what the agent selects. Commands are the slash entry points (`/openspec-propose`, and the `opsx-*` command files). They carry the same workflow. Further workflows (including verify and bulk-archive) are optional. Change the set with:

```bash
openspec config profile
openspec update
```

`openspec config profile` is global to the machine. Other repos pick it up on their next `openspec update`.

Other init flags:

| Flag | Effect |
|------|--------|
| `--tools <ids>` | `cursor`, a comma-separated list, `all`, or `none`. `none` writes only `openspec/config.yaml`. |
| `--language <language>` | Language instruction on a new project config. Rejected when `store:` points at an external store. |
| `--profile core\|custom` | Override the global profile for this run. `core` is the standard set. |
| `--force` | Clean older layouts without asking. |
| `--no-animation` | Static welcome text. |

`openspec init` with no `--tools` prompts in an interactive terminal. Outside one, it sets up tools it can detect, and exits 1 if it detects none.

Run init from the repository root. A subdirectory exits 1.

Where specs live:

- In this repo (default): specs and changes sit next to the code and are versioned with it. The bootstrapper uses this.
- In a store: a separate planning repo. That is a manual choice; `standards-init` does not register a store. See the upstream stores docs if several repos must share one planning root.

### Existing `openspec/project.md`

Init does not copy a legacy `openspec/project.md` into `config.yaml`. It leaves the file in place. Move useful lines yourself: project-wide constraints into `context`, artifact-specific lines into `rules`, apply/archive lines into `operations`. Delete `project.md` only after `config.yaml` looks right. See [CONFIGURATION.md](CONFIGURATION.md).

## Update

In each repo where you ran init:

```bash
openspec update
```

That refreshes generated skills and commands. They do not update on their own. When a newer CLI exists, `openspec update` says so.

CLI upgrade depends on how you installed it:

| Install | Upgrade |
|---------|---------|
| Standalone | `openspec install` (replaces the binary in place). `openspec update` reports when a newer one exists. |
| npm | `npm install -g @fission-ai/openspec@latest` |
| Homebrew | `brew upgrade openspec` |
| Deno | Re-run the Deno install with `-f` |
| Nix | `nix profile upgrade openspec` |

A global npm install belongs to one Node installation. After switching Node versions (nvm and similar), install the CLI again under the new Node.

`openspec-setup.sh` does not upgrade a CLI that is already on `PATH`. Run the matching command above, then `openspec update` in the product repo.

## Switch from npm or Homebrew to standalone

Optional. The previous install keeps working. Projects do not need `openspec init` again.

```bash
openspec install
```

Then remove the old copy, using the command `openspec install` prints. Until that copy is gone it stays first on `PATH`. Example:

```bash
npm uninstall -g @fission-ai/openspec
```

Open a new terminal:

```bash
openspec version
```

Expect `OpenSpec (standalone)`. If it names a package manager, another copy is still on `PATH`. `which -a openspec` (Windows: `where.exe openspec`) lists them.

## Uninstall

None of these steps delete application source. Pause before removing `openspec/`: `specs/` and `changes/archive/` are the spec record and stay readable as Markdown without the CLI.

1. Remove completions while the CLI still exists, if you installed them:

```bash
openspec completion uninstall
```

2. Remove the CLI.

- Standalone: delete `~/.local/bin/openspec`. On Windows, delete `%LOCALAPPDATA%\Programs\openspec` and remove that directory from the user PATH.
- npm: `npm uninstall -g @fission-ai/openspec`
- Homebrew: `brew uninstall openspec`
- Deno: `deno uninstall --global openspec`
- Nix: `nix profile remove openspec`

3. Generated files, if you want them gone:

- Skills `openspec-*` and commands `opsx-*` under `.cursor/` (and `.claude/`, `.agents/`, or the other tool directories you initialized).
- Older marker blocks inside `CLAUDE.md` or `AGENTS.md` (delete the block, keep the file) and `opsx-*.md` prompts in `~/.codex/prompts`.
- Per-machine state: `~/.config/openspec/` (settings and telemetry id). Schema overrides, store registrations, and standalone built-in schemas live in `~/.local/share/openspec/` (Windows: `%APPDATA%\openspec` and `%LOCALAPPDATA%\openspec`). Registrations are pointers; the store repos they name are not deleted.

Configuration of `openspec/config.yaml` is in [CONFIGURATION.md](CONFIGURATION.md).
