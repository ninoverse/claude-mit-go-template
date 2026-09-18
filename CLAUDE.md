<!-- agentcfg:start -->
<!-- agentcfg:import · v0.17.6 -->
@AGENTS.md

<!-- language/go/automation.md · v0.17.6 -->
# Automation

`.claude/settings.json` allowlists the commands in *Build and test commands* so
they do not prompt, runs `gofmt` on every `.go` file you edit, and warns if the
module stops compiling when a turn ends. Formatting is therefore already handled
— do not run `make fmt` after each edit.
<!-- agentcfg:end -->
