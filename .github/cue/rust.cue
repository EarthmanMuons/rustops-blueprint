package workflows

rust: _#useMergeQueue & {
	name: "rust"

	env: {
		CARGO_INCREMENTAL: 0
		CARGO_TERM_COLOR:  "always"
		RUST_BACKTRACE:    1
		RUSTFLAGS:         "-D warnings"
	}

	jobs: {
		changes: _#detectFileChanges

		check: {
			name: "check"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "needs.changes.outputs.rust == 'true'"
			steps: [
				_#checkoutCode,
				_#installRust,
				_#cacheRust,
				_#cargoCheck,
			]
		}

		format: {
			name: "format"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "needs.changes.outputs.rust == 'true' && github.event_name == 'pull_request'"
			steps: [
				_#checkoutCode,
				_#installRust,
				_#cacheRust,
				{
					name: "Check formatting"
					run:  "cargo fmt --check"
				},
			]
		}

		lint: {
			name: "lint"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "needs.changes.outputs.rust == 'true' && github.event_name == 'pull_request'"
			steps: [
				_#checkoutCode,
				_#installRust,
				_#cacheRust,
				{
					name: "Check lints"
					run:  "cargo clippy --no-deps -- -D warnings"
				},
			]
		}

		test_stable: {
			name: "test / stable"
			needs: ["check", "format", "lint"]
			defaults: run: shell: "bash"
			strategy: {
				"fail-fast": false
				matrix: platform: [
					"macos-latest",
					"ubuntu-latest",
					"windows-latest",
				]
			}
			"runs-on": "${{ matrix.platform }}"
			if:        "needs.changes.outputs.rust == 'true' && always()"
			steps: [
				_#checkoutCode,
				_#installRust,
				_#installTool & {with: tool: "cargo-nextest"},
				_#cacheRust,
				{
					name: "Compile tests"
					run:  "cargo test --locked --no-run"
				},
				{
					name: "Run tests"
					run:  "cargo nextest run --locked"
				},
				{
					name: "Run doctests"
					run:  "cargo test --locked --doc"
				},
			]
		}

		// Minimum Supported Rust Version
		check_msrv: {
			name: "check / msrv"
			needs: ["check", "format", "lint"]
			"runs-on": defaultRunner
			if:        "needs.changes.outputs.rust == 'true' && always()"
			steps: [
				_#checkoutCode,
				{
					name: "Get MSRV from package metadata"
					id:   "msrv"
					run:  "awk -F '\"' '/rust-version/{ print \"version=\" $2 }' Cargo.toml >> $GITHUB_OUTPUT"
				},
				_#installRust & {with: toolchain: "${{ steps.msrv.outputs.version }}"},
				_#cacheRust,
				_#cargoCheck,
			]
		}

		merge_queue: needs: [
			"test_stable",
			"check_msrv",
		]
	}
}
