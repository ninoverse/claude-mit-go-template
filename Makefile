.DEFAULT_GOAL := help

# Pin golangci-lint to a concrete version; `@latest` is discouraged for it.
# The others stay on @latest deliberately: golangci-lint is the only one whose
# rule set changes what passes, so it is the only one that can turn a gate red
# without a commit. A newer vulnerability scanner is what you want.
GOLANGCI_LINT_VERSION := v2.12.2

.PHONY: help tools tools-lint tools-test tools-vuln tools-licenses tools-watch \
        build vet fmt fmt-check lint test test-race cover vuln licenses watch ci

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
	go install gotest.tools/gotestsum@latest

tools-vuln: ## Install govulncheck
	go install golang.org/x/vuln/cmd/govulncheck@latest

tools-licenses: ## Install go-licenses
	go install github.com/google/go-licenses/v2@latest

tools-watch: ## Install air
	go install github.com/air-verse/air@latest

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
