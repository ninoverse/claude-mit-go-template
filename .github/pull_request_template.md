<!--
Title format: <type>(<scope>): <description>, under 72 characters.
See .claude/pr-guidelines.md and .claude/commit-conventions.md.
-->

## What
<!-- One-paragraph summary of the change -->

## Why
<!-- Motivation: bug, feature request, refactor reason -->

## How
<!-- Non-obvious implementation decisions. Skip what the diff already says. -->

## Testing
<!-- What you ran, and what it proved. Say plainly if a gate could not run. -->

---

- [ ] `make ci` passes — every gate, zero findings
- [ ] One logical change, in one commit
- [ ] Exported identifiers have doc comments; every returned error is handled
- [ ] The `go` directive in `go.mod` was not bumped incidentally
