---
description: Add a package to the module following the 9-step package workflow
argument-hint: <package-name> [one-line description of what it does]
---

Add a new package named `$1` to this module.

Read `.claude/package-workflow.md` in full before doing anything, then follow all
nine steps in order. Do not skip, reorder, or batch them.

Full request: $ARGUMENTS

The pre-flight rules in that file still apply:

1. State what the package will contain and **wait for explicit approval** before
   writing any code.
2. Check whether `internal/$1/` already exists. If it does, stop and ask whether
   to skip, overwrite, or modify. Never silently overwrite.

Decide the location before scaffolding: `internal/$1/` for a private package,
`cmd/$1/main.go` for an executable, `pkg/$1/` only if it is genuinely meant for
import from outside this module.

Points that are easy to get wrong, so verify each one before committing:

- A **package comment** (`// Package $1 …`) on one file, and a doc comment
  starting with the identifier's own name on every exported identifier. `revive`
  enforces both, so the package is red without them.
- Imports of this module are grouped last by `goimports`. An import block that
  `gofmt` accepts can still fail `make fmt-check`.
- Every returned `error` is checked in non-test code — `errcheck` is on, and
  `_ =` does not satisfy it. Errors are wrapped with `%w` as they propagate.
- At least one test, table-driven with subtests where there are multiple cases.
- `make ci` passes before you commit.

If `internal/greet` and `cmd/app` are still present, they are placeholders — the
module needs at least one package for `go vet ./...` and `go test ./...` to
return zero, and the Dockerfile builds `./cmd/app`. Removing them is a separate
change from adding this one, and only once a real package covers both roles.

Finish at step 9: one commit, push the branch, output the PR title and
description, then stop. Do not open the PR — see `.claude/git-flow.md`.
