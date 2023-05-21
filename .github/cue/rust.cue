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

		format: {
			name: "format"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "needs.changes.outputs.rust == 'true'"
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "rustfmt"},
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
			if:        "needs.changes.outputs.rust == 'true'"
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "clippy"},
				_#cacheRust,
				{
					name: "Check lints"
					run:  "cargo clippy --locked --all-targets --all-features -- -W clippy::pedantic -D warnings"
				},
			]
		}

		test_stable: {
			name: "test / stable"
			needs: ["format", "lint"]
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
			steps: [
				_#checkoutCode,
				_#installRust,
				_#cacheRust & {with: "shared-key": "stable-${{ matrix.platform }}"},
				for step in _testRust {step},
			]
		}

		// Minimum Supported Rust Version
		test_msrv: {
			name: "test / msrv"
			needs: ["format", "lint"]
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				for step in _setupMsrv {step},
				_#cacheRust & {with: "shared-key": "msrv-\(defaultRunner)"},
				for step in _testRust {step},
			]
		}

		merge_queue: needs: [
			"changes",
			"format",
			"lint",
			"test_stable",
			"test_msrv",
		]
	}
}
