Scaffolding for new Go module projects: a pinned toolchain, the merge gates wired to CI, and the agent rules already in place. Fork or copy it to start a project.

<!-- agentcfg:start -->
<!-- language/go/tooling.md · v0.17.6 -->
# Build and test commands

**Toolchain:** The Go version is pinned via the `go` and `toolchain` directives in `go.mod` (mirrored in `.go-version`). With `GOTOOLCHAIN=auto` (the default) every contributor automatically downloads the pinned toolchain on first `go` invocation. The full-parity dev tools are `golangci-lint` (lint + format), `gotestsum` (test runner), `govulncheck` (CVE scan), `go-licenses` (license check), and `air` (live reload).

Commands live in the `Makefile`, which is the single source of truth — do not
copy the underlying go invocations into docs or CI, call the target.

```bash
make            # list every target
make ci         # every merge gate, in order — run this before every commit
make build      # build all packages
make fmt        # format in place
make fmt-check  # gate 1
make vet        # gate 2, first half
make lint       # gate 2 — golangci-lint
make test-race  # gate 3 — race detector plus coverage
make vuln       # gate 4 — govulncheck
make licenses   # gate 4 — go-licenses
make cover      # coverage summary
make watch      # dev loop, live reload
```

Install the auxiliary tools once per machine:

```bash
make tools      # golangci-lint, gotestsum, govulncheck, go-licenses, air
```

`make tools-lint`, `tools-test`, `tools-vuln` and `tools-licenses` install one at
a time; that is how CI does it, so each gate pulls only the binary it uses.

## Architecture & Module Rules

**Layout:** A single Go module rooted at the repo. The module path is declared in `go.mod`; dependency versions are centralized in that one file. Code follows the standard Go layout:

- `cmd/<binary>/main.go` — one directory per executable (`package main`).
- `internal/<pkg>/` — private packages, importable only within this module.
- `pkg/<pkg>/` — public packages intended for external import (omit if there are none).

**Packages:** One package per directory; the directory name matches the `package` clause. A new package is just a new directory with a `package` declaration — there is no per-package manifest. Cross-package use is a plain `import "<module-path>/internal/<pkg>"`, with the module path from `go.mod`. New dependencies are added with `go get` and land in `go.mod`/`go.sum`.

**Go version:** The minimum language version is the `go` directive in `go.mod` (the analog of an MSRV). Do not lower it incidentally. There are no editions, no LTO/codegen profiles, and `gofmt` is non-configurable by design.

<!-- core/behavior.md · v0.17.6 -->
# Behavioral guidelines

**Maintain the Build:** Never leave the codebase in a state where build, lint,
or tests fail. Run the relevant commands in *Build and test commands* to verify
your work before concluding a task.

**Tradeoff:** Bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly. If uncertain, stop and ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, propose it. Push back when warranted.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked. No abstractions for single-use code.
- No "flexibility" or error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Match existing style exactly.
- Remove imports/variables/functions that YOUR changes made unused. Don't remove pre-existing dead code unless asked.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

- Transform tasks into verifiable goals (e.g., "Add validation" → "Write tests for invalid inputs, then make them pass").
- For multi-step tasks, state a brief plan and verify each step independently.

<!-- concerns/template/rules.md · v0.17.6 -->
# Template repository

This repository is a GitHub template: new projects start as a copy of it, and
every copy inherits everything here.

- Keep the example code minimal. It demonstrates the conventions and keeps the
  gates green on a fresh copy; it holds no real business logic.
- Where the template ships placeholder packages, they exist because the
  toolchain fails on an empty module and the `Dockerfile` needs a
  binary to build. Remove a placeholder only once a real package covers its
  role, as a change of its own, and point the `Dockerfile` at the real binary in
  that change.
- A project created from this template removes `template` from `concerns` in its
  `.agentprofile.yml`.

<!-- agentcfg:index · v0.17.6 -->
# Extended rules

Read these when they apply; they are not loaded by default.

**By activity:**

- **Any change that ends in a PR:** [Git flow](.agents/git-flow.md) and [Releases and deploys](.agents/service-release.md)
- **Creating branches:** [Branch naming](.agents/branch-naming.md)
- **Reviewing PRs:** [Code review](.agents/code-review.md) and [Go code review](.agents/go-code-review.md)
- **Committing code:** [Commit message guidelines](.agents/commit-conventions.md)
- **Deciding what to build next / branching strategy:** [Execution order](.agents/execution-order.md)
- **Opening PRs:** [PR instructions](.agents/pr-guidelines.md)
- **Creating new files:** [Directories and file naming](.agents/go-file-naming.md)
- **Checking your work:** [Merge gates](.agents/gates.md)
- **Adding or modifying a package:** [Adding a package](.agents/new-package.md)
- **Testing/Verifying:** [Testing instructions](.agents/go-testing.md)
<!-- agentcfg:end -->
