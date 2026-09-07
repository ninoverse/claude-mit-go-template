# Claude Code Go Template

[![CI](https://github.com/ninoverse/claude-mit-go-template/actions/workflows/ci.yml/badge.svg)](https://github.com/ninoverse/claude-mit-go-template/actions/workflows/ci.yml)
[![Audit](https://github.com/ninoverse/claude-mit-go-template/actions/workflows/audit.yml/badge.svg)](https://github.com/ninoverse/claude-mit-go-template/actions/workflows/audit.yml)

Claude Code configuration scaffolding for **Go module** projects.
Fork or copy this repo to start a new Go project that ships with a pinned
toolchain, opinionated lint/format/test commands, and Claude Code rule
files already wired up.

## What's bundled

| File | Purpose |
|------|---------|
| `go.mod` | Module root. Module path, the `go`/`toolchain` version pin, and the (centralized) dependency graph. |
| `.go-version` | Single-line Go version mirroring the `toolchain` pin, for version managers (`goenv`/`asdf`/`gimme`) and CI. |
| `.golangci.yml` | `golangci-lint` v2 config: linters + the `gofmt`/`goimports` formatters. |
| `Makefile` | Task runner. Canonical form of every command; CI and the rules call these targets. |
| `.air.toml` | `air` live-reload config. |
| `.github/workflows/ci.yml` | Calls the org's reusable `go-ci.yml`: the gates, a Go floor job and a coverage artifact. Sets the triggers and the Go version. |
| `.github/workflows/audit.yml` | Calls the org's reusable `go-audit.yml`: `govulncheck` on a cron. |
| `.github/workflows/bump-version.yml` | Calls the org's `go-bump-version.yml`: reads the commit type, pushes a SemVer tag. |
| `.github/workflows/release.yml` | Calls the org's `release-cloudrun.yml` on that tag. |
| `renovate.json` | One line extending the org's shared preset. Renovate runs centrally; there is no workflow or token here. |
| `Dockerfile` / `.dockerignore` | Multi-stage Go build → distroless image, for container / Cloud Run deploys. |
| `.gitignore` | Ignores binaries, coverage output, and `go.work`. |
| `cmd/`, `internal/` | Standard Go layout dirs — add binaries under `cmd/<name>/` and private packages under `internal/<name>/`. |
| `cmd/app`, `internal/greet` | Placeholders. `go vet ./...` and `go test ./...` both exit 1 on a module with no packages, and the Dockerfile builds `./cmd/app`. Delete them *after* adding your own. |
| `CONTRIBUTING.md` | Setup, the git flow, the gates — the short version of the `.claude/` rules. |
| `.github/CODEOWNERS` | Review ownership, weighted toward the rule files and CI. |
| `.github/pull_request_template.md` | The same What/Why/How/Testing template `.claude/pr-guidelines.md` specifies. |
| `CLAUDE.md` | Top-level rules surfaced to Claude Code. |
| `.claude/*.md` | Per-task rule files (see table below). |
| `.claude/settings.json` | Permission allowlist + hooks: gofmt on save, `go build` when Claude stops. |
| `.claude/commands/` | Project slash commands: `/gates`, `/new-package`. |

### Not in this repository

`SECURITY.md`, `CODE_OF_CONDUCT.md` and `.github/ISSUE_TEMPLATE/` come from
[`ninoverse/.github`](https://github.com/ninoverse/.github), which GitHub serves
as the default to every repository in the organization that has none of its own.
They are not here because both hardcode `ninoverse` URLs, so a copy would be
wrong for anyone else anyway.

`CONTRIBUTING.md` and the pull request template stay, because overriding is
all-or-nothing per file and both are dense with Go and `make` specifics the
generic versions deliberately drop.

## Bootstrap a project from this template

```bash
# 1. Clone and rename
git clone https://github.com/ninoverse/claude-mit-go-template my-project
cd my-project
rm -rf .git && git init

# 2. Set your module path (rewrites go.mod + run the goimports local-prefixes)
go mod edit -module github.com/<you>/<my-project>
#    then update local-prefixes in .golangci.yml to match.

# 3. Install the auxiliary tools (once per machine)
make tools

# 4. Add your first package, then drop the placeholders
mkdir -p internal/<your-pkg>      # or: mkdir -p cmd/<your-binary>
rm -rf internal/greet cmd/app     # only once yours covers both roles

# 5. Verify the toolchain and module
make ci
```

### If you forked this

`.github/workflows/` calls reusable workflows from
[`ninoverse/.github`](https://github.com/ninoverse/.github). That repository is
public and the calls are pinned to `@v1`, so `ci.yml` and `audit.yml` keep
working in your fork with no setup — but the job definitions are then maintained
by someone else. To own them outright, copy
[`go-ci.yml`](https://github.com/ninoverse/.github/blob/main/.github/workflows/go-ci.yml)
and
[`go-audit.yml`](https://github.com/ninoverse/.github/blob/main/.github/workflows/go-audit.yml)
into your own `.github/workflows/` and drop the `uses:` line. They call the same
`make` targets either way.

`bump-version.yml` and `release.yml` will *not* work in a fork as-is: they need
organization-level GitHub App and Google Cloud credentials that a fork does not
inherit. `renovate.json` points at the same organization's preset — replace it
with your own policy.

Community health files (`SECURITY.md`, issue forms) also come from that
repository. GitHub serves organization defaults only within the owning
organization, so **your fork inherits nothing** — add your own, or GitHub will
show none.

## Daily commands

The `Makefile` is the single source of truth for every command — CI and the
`.claude/` rules call these targets rather than repeating go invocations.

```bash
make            # list every target
make ci         # every merge gate — run before every commit
make build      # build all packages
make fmt        # format in place
make test-race  # tests with the race detector and coverage
make cover      # coverage summary
make vuln       # CVE scan
make watch      # live reload
```

## The gates

`make ci` runs `fmt-check` · `vet` · `lint` · `test-race` · `vuln` · `licenses`.
CI runs the same targets as separate jobs, so a red check names the gate that
broke, plus a `Go <version>` job that builds with `GOTOOLCHAIN=local`.

That last one is not an MSRV job, whatever it looks like — Go enforces the `go`
directive on every build, in every job. What it catches is a dependency
requiring a newer Go, which under the default `GOTOOLCHAIN=auto` makes the
toolchain silently download it and succeed, leaving the declared floor a lie. It
also compares the `go-version` input in `ci.yml` against `go.mod`, so raising the
Go version in one place and not the other fails there rather than drifting.

## Dependency updates

Renovate runs **centrally**, from
[`ninoverse/.github`](https://github.com/ninoverse/.github) — there is no
workflow and no token in this repository. `renovate.json` is one line extending
the shared preset; deleting it opts this repository out entirely.

Two pins Renovate cannot reach, because they are `go install` lines and
directives rather than module requirements: `GOLANGCI_LINT_VERSION` in the
Makefile, and the Go version itself. See
[`CONTRIBUTING.md`](CONTRIBUTING.md#dependency-updates).

## Rule files

| File | Purpose |
|------|---------|
| `.claude/git-flow.md` | The branch → commit → PR loop. One branch in flight, no stacked PRs |
| `.claude/branch-naming.md` | Branch prefix and format conventions |
| `.claude/commit-conventions.md` | Conventional Commits rules |
| `.claude/pr-guidelines.md` | PR title, description template, size guidance |
| `.claude/testing-requirements.md` | Test gates (fmt, vet, lint, test, vuln, licenses) |
| `.claude/file-naming.md` | Module layout and Go naming conventions |
| `.claude/code-review.md` | Review checklist (lint, error handling, docs, deps) |
| `.claude/package-workflow.md` | Step-by-step procedure to add a package |
| `.claude/execution-order.md` | What order to build things in, and one PR per what |
