package workflows

preloadCache: {
	name: "preload-cache"

	on: {
		push: {
			branches: [defaultBranch]
			paths: [
				"**/Cargo.lock",
				"**/Cargo.toml",
				".github/workflows/rust.yml",
			]
		}

		// Run every Monday at 7:45am UTC to cover any upstream Rust stable release.
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

	jobs: {
		check_stable: {
			name: "check / stable"
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
				_#cacheRust,
				_#installTool & {with: tool: "cargo-nextest"},
				_#cargoCheck,
			]
		}

		// Minimum Supported Rust Version
		check_msrv: {
			name:      "check / msrv"
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
	}
}
