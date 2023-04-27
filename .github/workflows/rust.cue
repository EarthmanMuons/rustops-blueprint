package workflows

rust: _#borsWorkflow & {
	name: "rust"

	on: {
		pull_request: branches: [defaultBranch]
		push: branches: defaultPushBranches
	}

	env: {
		CARGO_INCREMENTAL: 0
		CARGO_TERM_COLOR:  "always"
		RUST_BACKTRACE:    1
		RUSTFLAGS:         "-D warnings"
	}

	jobs: {
		check: {
			name:      "check"
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				_#installRust,
				_#cacheRust,
				_#cargoCheck,
			]
		}

		format: {
			name:      "format"
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "clippy,rustfmt"},
				_#cacheRust,
				{
					name: "Check formatting"
					run:  "cargo fmt --check"
				},
			]
		}

		lint: {
			name:      "lint"
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "clippy,rustfmt"},
				_#cacheRust,
				{
					name: "Check lints"
					run:  "cargo clippy -- -D warnings"
				},
			]
		}

		testStable: {
			name: "test / stable"
			needs: ["check", "format", "lint"]
			strategy: {
				"fail-fast": false
				matrix: {
					platform: [
						"macos-latest",
						"ubuntu-latest",
						"windows-latest",
					]
				}
			}
			"runs-on": "${{ matrix.platform }}"
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

		// Minimum Supported Rust Version
		checkMsrv: {
			name: "check / msrv"
			needs: ["check", "format", "lint"]
			"runs-on": defaultRunner
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

		bors: needs: [
			"testStable",
			"checkMsrv",
		]
	}
}
