# CLAUDE.md

This file provides strict guidance and architectural rules for Claude Code (claude.ai/code) when working in this repository.

## Commands & Tooling

- **Toolchain:** The Go version is pinned via the `go` and `toolchain` directives in `go.mod` (mirrored in `.go-version`). With `GOTOOLCHAIN=auto` (the default) every contributor automatically downloads the pinned toolchain on first `go` invocation. The full-parity dev tools are `golangci-lint` (lint + format), `gotestsum` (test runner), `govulncheck` (CVE scan), `go-licenses` (license check), and `air` (live reload).
- **Maintain the Build:** Never leave the codebase in a state where build, lint, or tests fail. Run the relevant commands below to verify your work before concluding a task.

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

**Automation:** `.claude/settings.json` allowlists these commands so they do not
prompt, runs `gofmt` on every `.go` file you edit, and warns if the module stops
compiling when a turn ends. Formatting is therefore already handled — do not run
`make fmt` after each edit.

## Architecture & Module Rules

**Layout:** A single Go module rooted at the repo. The module path is declared in `go.mod`; dependency versions are centralized in that one file. Code follows the standard Go layout:

- `cmd/<binary>/main.go` — one directory per executable (`package main`).
- `internal/<pkg>/` — private packages, importable only within this module.
- `pkg/<pkg>/` — public packages intended for external import (omit if there are none).

**Packages:** One package per directory; the directory name matches the `package` clause. A new package is just a new directory with a `package` declaration — there is no per-package manifest. Cross-package use is a plain `import "github.com/ninoverse/claude-mit-go-template/internal/<pkg>"`. New dependencies are added with `go get` and land in `go.mod`/`go.sum`.

**Go version:** The minimum language version is the `go` directive in `go.mod` (the analog of an MSRV). Do not lower it incidentally. There are no editions, no LTO/codegen profiles, and `gofmt` is non-configurable by design.

## Behavioral Guidelines

**Tradeoff:** Bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State your assumptions explicitly. If uncertain, stop and ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, propose it. Push back when warranted.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked. No abstractions for single-use code.
- No "flexibility" or error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Match existing style exactly.
- Remove imports/variables/functions that YOUR changes made unused. Don't remove pre-existing dead code unless asked.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

- Transform tasks into verifiable goals (e.g., "Add validation" → "Write tests for invalid inputs, then make them pass").
- For multi-step tasks, state a brief plan and verify each step independently.

---

## Extended Rules (Read Before Acting)

Use your file-reading capabilities to read the exact rules in the `.claude/` directory **before** executing any of the following tasks:

- **Any change that ends in a PR:** Read `.claude/git-flow.md` **first** — it defines the branch → commit → PR loop everything else fits inside
- **Adding a package:** `/new-package <name>` runs the `.claude/package-workflow.md` checklist
- **Checking your work:** `/gates` reports which of the merge gates pass
- **Committing code:** Read `.claude/commit-conventions.md`
- **Creating branches:** Read `.claude/branch-naming.md`
- **Reviewing PRs:** Read `.claude/code-review.md`
- **Testing/Verifying:** Read `.claude/testing-requirements.md`
- **Opening PRs:** Read `.claude/pr-guidelines.md`
- **Creating new files:** Read `.claude/file-naming.md`
- **Building a package:** Read `.claude/package-workflow.md`
- **Deciding what to build next / branching strategy:** Read `.claude/execution-order.md`
