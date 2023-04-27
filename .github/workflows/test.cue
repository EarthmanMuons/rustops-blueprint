package workflows

test: _#borsWorkflow & {
	name: "test"

	on: {
		pull_request: branches: [defaultBranch]
		push: branches: defaultPushBranches
	}

	concurrency: {
		group:                "${{ github.workflow }}-${{ github.head_ref || github.run_id }}"
		"cancel-in-progress": true
	}

	env: {
		CARGO_INCREMENTAL: 0
		CARGO_TERM_COLOR:  "always"
		RUST_BACKTRACE:    1
		RUSTFLAGS:         "-D warnings"
	}

	jobs: _#defaultJobs & {
		required: {
			name: "linux / stable"
			steps: [
				_#checkoutCode,
				_#installRust,
				{
					name: "Install cargo-nextest"
					uses: "taiki-e/install-action@7522ae03ca435a0ad1001ca93d6cd7cb8e81bd2f"
					with: tool: "cargo-nextest"
				},
				_#cacheRust,
				{
					name: "Compile tests"
					run:  "cargo test --locked --no-run"
				},
				{
					name: "Run tests"
					run:  "cargo nextest run --locked"
				},
			]
		}

		bors: needs: ["required"]
	}
}
