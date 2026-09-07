# Contributing

The rules that govern this repository live in [`CLAUDE.md`](CLAUDE.md) and
[`.claude/`](.claude/). They are written for Claude Code but they are not
agent-specific — they are the conventions, and they apply to humans identically.
This file is the short version and points at the authoritative one for each
topic.

## Setup

```bash
make tools      # golangci-lint, gotestsum, govulncheck, go-licenses, air
make ci         # confirm a clean checkout passes
```

The Go version comes from [`go.mod`](go.mod) and [`.go-version`](.go-version).
`make tools` installs each binary separately, so if you only need one gate,
`make tools-lint`, `tools-test`, `tools-vuln` and `tools-licenses` exist too —
that is how CI installs them.

## The loop

One branch, one commit, one PR, merged before the next begins. No stacked PRs.

```bash
git switch main && git pull --ff-only
git switch -c <type>/<short-description>     # .claude/branch-naming.md
# ... change ...
make ci                                      # must pass before you push
git commit                                   # .claude/commit-conventions.md
git push -u origin <branch>
```

Then open a PR using the template. If Claude Code prepared the branch, it stops
before opening the PR by design — that step is yours.

Because a branch is only pushed once the gate already passes, there is no
work-in-progress state to represent. Draft PRs are not used.

## The gates

```bash
make ci
```

`fmt-check` · `vet` · `lint` · `test-race` · `vuln` · `licenses`. All of them,
zero findings, before you push. CI runs the same targets, one job per gate, plus
a job that builds with `GOTOOLCHAIN=local` so a dependency cannot quietly raise
the toolchain out from under the `go` directive.
See [`.claude/testing-requirements.md`](.claude/testing-requirements.md).

Two that catch people out:

- `golangci-lint fmt --diff` is the formatting gate, not `gofmt`. It runs
  `goimports` as well, with the module's own prefix grouped last — so an import
  block that `gofmt` accepts can still fail.
- `revive` requires a doc comment on every exported identifier *and* a package
  comment on every package. A new package fails `make lint` until it has one.

## Adding a package

Follow [`.claude/package-workflow.md`](.claude/package-workflow.md). Binaries go
under `cmd/<name>/`, everything private under `internal/<name>/`.

`internal/greet` and `cmd/app` are placeholders. Delete them once you have a real
package — but not before, and not one without the other: `go vet ./...` and
`go test ./...` both exit 1 on a module with no packages at all, and the
Dockerfile builds `./cmd/app`.

## What gets declined

This template biases toward simplicity. Additions that only serve one downstream
project, abstractions with a single caller, and configuration for situations that
have not happened yet are likely to be turned down.

## Dependency updates

Renovate opens them. It runs **centrally**, from
[`ninoverse/.github`](https://github.com/ninoverse/.github), so there is no
workflow and no token in this repository. `renovate.json` here is one line
extending the shared preset; deleting it would opt this repository out.

Review the changelog rather than rubber-stamping. The usual reason a green
repository suddenly goes red is a dependency raising its own `go` directive above
this module's — which surfaces as a build failure, not as a dependency error.

Majors wait for approval on the Dependency Dashboard issue; everything
non-breaking arrives as one grouped PR on Monday. Security fixes ignore the
schedule entirely.

Two pins Renovate does not manage, because they are `go install` lines in the
Makefile rather than module requirements: `GOLANGCI_LINT_VERSION`, and the Go
version itself. Raising the Go version is a deliberate edit to `go.mod`,
`.go-version`, the `Dockerfile` and the `go-version` input in
`.github/workflows/ci.yml` together — CI compares the last of those against
`go.mod` on every run, so a partial bump fails rather than drifting.

Anything that should change for *every* project — the schedule, the grouping,
the major-approval gate — belongs in the org preset, not here. Overriding it
locally is possible but reintroduces exactly the drift centralizing removed.

## If you forked this

Four things in this repository point at `ninoverse` and will not work as-is:

- `renovate.json` extends `github>ninoverse/.github`. Replace it with your own
  policy, or point it at your own preset.
- `.github/workflows/ci.yml` and `audit.yml` call reusable workflows from that
  same repository. They are public and pinned to `@v1`, so they keep working —
  see the README for how to vendor them instead.
- `.github/workflows/bump-version.yml` and `release.yml` do the same, and also
  need organization-level app and Google Cloud credentials that a fork does not
  inherit.
- `.github/CODEOWNERS` names `@nicolapasqua99`.

`SECURITY.md`, `CODE_OF_CONDUCT.md` and the issue forms are **not** in this
repository; they come from the organization defaults, which a fork does not
inherit. Add your own.
