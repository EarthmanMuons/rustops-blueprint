package workflows

scheduled: {
	name: "scheduled"

	on: {
		// Run every Monday at 7:45am UTC.
		schedule: [{cron: "45 7 * * 1"}]

		// Allow manually running this workflow.
		workflow_dispatch: null
	}

	concurrency: {
		group:                "${{ github.workflow }}-${{ github.ref }}"
		"cancel-in-progress": true
	}

	env: {
		CARGO_INCREMENTAL: 0
		CARGO_TERM_COLOR:  "always"
		RUST_BACKTRACE:    1
		RUSTFLAGS:         "-D warnings"
	}

	jobs: direct_minimal_versions: {
		name:      "direct-minimal-versions / stable"
		"runs-on": defaultRunner
		steps: [
			_#checkoutCode & {with: ref: defaultBranch},
			_#installRust,
			_#installRust & {with: toolchain: "nightly"},
			{
				name: "Default to stable Rust"
				run:  "rustup default stable"
			},
			{
				name: "Resolve minimal dependency versions instead of maximum"
				run:  "cargo +nightly update -Z direct-minimal-versions"
			},
			for step in _testRust {step},
		]
	}
}
