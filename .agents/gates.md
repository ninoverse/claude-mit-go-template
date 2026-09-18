<!-- agentcfg:start -->
<!-- language/go/tasks/gates.md · v0.17.6 -->
# Merge gates

Run the merge gates defined in *Testing instructions*:

```
make ci
```

If a tool is missing, `make tools-lint`, `tools-test`, `tools-vuln` and
`tools-licenses` install them one gate at a time. Say which was missing rather
than installing silently.

Extra arguments, if any: $ARGUMENTS

Then report a one-line-per-gate summary:

- Which gates passed and which failed.
- For each failure, the specific file and line, and the actual error — not a
  paraphrase.
- Whether any gate could not run because its tool is not installed. Do not
  report a skipped gate as a passing gate.

`make ci` stops at the first failing target, so a gate listed after the failure
has not run. Report those as not run, not as passing.

Do not fix anything unless asked. This command reports; it does not edit.
<!-- agentcfg:end -->
