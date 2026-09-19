.DEFAULT_GOAL := help

# Every tool is pinned, and the custom manager in renovate.json bumps these
# lines. Only golangci-lint was pinned before, on the grounds that its rule set
# is the only thing that can turn a gate red without a commit. That premise does
# not hold: go-licenses is built by whatever Go is installed and then fails to
# read a standard library newer than the one that built it, and govulncheck
# v1.8.0 requires a Go newer than this module targets. Neither is a rule change
# and both arrive without a commit, which is the property the pin is for.
#
# renovate: datasource=go depName=github.com/golangci/golangci-lint/v2
GOLANGCI_LINT_VERSION := v2.12.2
# renovate: datasource=go depName=gotest.tools/gotestsum
GOTESTSUM_VERSION := v1.13.0
# renovate: datasource=go depName=golang.org/x/vuln
GOVULNCHECK_VERSION := v1.8.0
# renovate: datasource=go depName=github.com/google/go-licenses/v2
GO_LICENSES_VERSION := v2.0.1
# renovate: datasource=go depName=github.com/air-verse/air
AIR_VERSION := v1.67.4

.PHONY: help tools tools-lint tools-test tools-vuln tools-licenses tools-watch \
        build vet fmt fmt-check lint test test-race cover vuln licenses watch ci \
        agentcfg

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

tools: tools-lint tools-test tools-vuln tools-licenses tools-watch ## Install every dev tool (once per machine)

# Split per gate so CI installs only what the gate it is running needs. These
# arrive by `go install` rather than as prebuilt binaries, so installing all
# five for every job would cost more than the gates themselves.
tools-lint: ## Install golangci-lint
	go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)

tools-test: ## Install gotestsum
	go install gotest.tools/gotestsum@$(GOTESTSUM_VERSION)

tools-vuln: ## Install govulncheck
	go install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)

tools-licenses: ## Install go-licenses
	go install github.com/google/go-licenses/v2@$(GO_LICENSES_VERSION)

tools-watch: ## Install air
	go install github.com/air-verse/air@$(AIR_VERSION)

build: ## Build all packages
	go build ./...

vet: ## Run go vet
	go vet ./...

fmt: ## Format the code (writes changes)
	golangci-lint fmt

fmt-check: ## Gate 1 — formatting is clean
	golangci-lint fmt --diff

lint: ## Gate 2 — the linters, plus go vet above
	golangci-lint run ./...

test: ## Run tests (falls back to `go test` if gotestsum is missing)
	@if command -v gotestsum >/dev/null 2>&1; then \
		gotestsum -- ./...; \
	else \
		echo "note: gotestsum not installed, falling back to go test" >&2; \
		go test ./...; \
	fi

test-race: ## Gate 3 — tests with the race detector and coverage
	@if command -v gotestsum >/dev/null 2>&1; then \
		gotestsum -- -race -coverprofile=coverage.txt -covermode=atomic ./...; \
	else \
		echo "note: gotestsum not installed, falling back to go test" >&2; \
		go test -race -coverprofile=coverage.txt -covermode=atomic ./...; \
	fi

cover: test-race ## Show the coverage summary
	go tool cover -func=coverage.txt

vuln: ## Gate 4 — known vulnerabilities
	govulncheck ./...

licenses: ## Gate 4 — dependency licenses
	go-licenses check ./...

watch: ## Dev loop with live reload (requires air)
	air

ci: fmt-check vet lint test-race vuln licenses ## Run the full verification gate

# `make agentcfg ARGS=check` is what someone runs after editing their profile,
# and the point is that it needs nothing installed: the published binary is
# static, and this repository has no Rust toolchain to build one with. The
# version comes from `.agentprofile.yml`, so the cache cannot drift from the pin
# — a bump fetches a new file rather than reusing a stale one — and `.agentcfg/`
# is gitignored, so nothing downloaded is ever committed.
agentcfg: ## Run the pinned agentcfg, e.g. `make agentcfg ARGS=check`
	@set -eu; \
	if [ ! -f .agentprofile.yml ]; then \
		echo "no .agentprofile.yml here — this target is for a repository agentcfg manages" >&2; \
		exit 1; \
	fi; \
	version=$$(sed -n 's/^config_version:[[:space:]]*//p' .agentprofile.yml); \
	case "$$(uname -s)/$$(uname -m)" in \
		Linux/x86_64)                target=x86_64-unknown-linux-musl ;; \
		Linux/aarch64 | Linux/arm64) target=aarch64-unknown-linux-musl ;; \
		Darwin/arm64)                target=aarch64-apple-darwin ;; \
		*) \
			echo "no agentcfg binary for $$(uname -s)/$$(uname -m) — published: linux-musl x86_64 and aarch64, darwin aarch64" >&2; \
			exit 1 ;; \
	esac; \
	binary=".agentcfg/agentcfg-$${version}"; \
	if [ ! -x "$${binary}" ]; then \
		mkdir -p .agentcfg; \
		curl -fsSL -o "$${binary}" \
			"https://github.com/ninoverse/agent-config-sync/releases/download/$${version}/agentcfg-$${target}"; \
		chmod +x "$${binary}"; \
	fi; \
	exec "$${binary}" $(ARGS)
