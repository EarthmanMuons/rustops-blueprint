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
			if:        "github.event_name == 'pull_request' && needs.changes.outputs.rust == 'true'"
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
			if:        "github.event_name == 'pull_request' && needs.changes.outputs.rust == 'true'"
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
			needs: ["changes", "format", "lint"]
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
			if:        "always() && needs.changes.outputs.rust == 'true'"
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
			needs: ["changes", "format", "lint"]
			"runs-on": defaultRunner
			if:        "always() && needs.changes.outputs.rust == 'true'"
			steps: [
				_#checkoutCode,
				for step in _setupMsrv {step},
				_#cacheRust & {with: "shared-key": "msrv-\(defaultRunner)"},
				for step in _testRust {step},
			]
		}

		merge_queue: needs: [
			"changes",
			"test_stable",
			"test_msrv",
		]
	}
}
