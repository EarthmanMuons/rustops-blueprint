package workflows

preloadCaches: {
	name: "preload-caches"

	on: {
		push: {
			branches: [defaultBranch]
			paths: [
				"**/Cargo.lock",
				"**/Cargo.toml",
				".github/workflows/rust.yml",
			]
		}

		// Run every Monday at 7:45am UTC,
		// to help cover tool changes and any upstream Rust stable releases.
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
		flush_caches: {
			name: "flush caches"
			permissions: {
				// required to delete caches
				actions: "write"
			}
			if:        "github.event_name == 'workflow_dispatch'"
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				{
					name: "Flush \(defaultBranch) branch caches"
					env: GH_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
					run: """
						gh extension install actions/gh-actions-cache
						REPO=${{ github.repository }}
						BRANCH="refs/heads/\(defaultBranch)"
						cacheKeys=$(gh actions-cache list -R $REPO -B $BRANCH | cut -f 1)
						set +e
						for key in $cacheKeys; do
						    gh actions-cache delete "$key" -R $REPO -B $BRANCH --confirm
						done
						"""
				},
			]
		}

		cache_stable: {
			name: "cache / stable"
			needs: ["flush_caches"]
			if: "always()"
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
				_#installTool & {with: tool:       "cargo-nextest"},
				_#cargoCheck,
			]
		}

		// Minimum Supported Rust Version
		cache_msrv: {
			name: "cache / msrv"
			needs: ["flush_caches"]
			if:        "always()"
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				for step in _setupMsrv {step},
				_#cacheRust & {with: "shared-key": "msrv-\(defaultRunner)"},
				_#installTool & {with: tool:       "cargo-nextest"},
				_#cargoCheck,
			]
		}
	}
}
