package workflows

check: {
	name: "check"

	on: {
		pull_request: branches: [
			"main",
		]
		push: branches: [
			"main",
			"staging",
			"trying",
		]
	}

	concurrency: {
		group:                "${{ github.workflow }}-${{ github.head_ref || github.run_id }}"
		"cancel-in-progress": true
	}

	env: CARGO_TERM_COLOR: "always"

	jobs: {
		format: {
			name:      "stable / format"
			"runs-on": "ubuntu-latest"
			steps: [{
				name: "Checkout source code"
				uses: "actions/checkout@v3"
			}, {
				name: "Install stable Rust toolchain"
				uses: "dtolnay/rust-toolchain@stable"
				with: components: "clippy,rustfmt"
			}, {
				name: "Cache dependencies"
				uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
			}, {
				name: "Check formatting"
				run:  "cargo fmt --check"
			}]
		}

		lint: {
			name:      "stable / lint"
			"runs-on": "ubuntu-latest"
			steps: [{
				name: "Checkout source code"
				uses: "actions/checkout@v3"
			}, {
				name: "Install stable Rust toolchain"
				uses: "dtolnay/rust-toolchain@stable"
				with: components: "clippy,rustfmt"
			}, {
				name: "Cache dependencies"
				uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
			}, {
				name: "Check lints"
				run:  "cargo clippy -- -D warnings"
			}]
		}

		// Minimum Supported Rust Version
		msrv: {
			name:      "msrv / compile"
			"runs-on": "ubuntu-latest"
			steps: [{
				name: "Checkout source code"
				uses: "actions/checkout@v3"
			}, {
				name: "Get MSRV from package metadata"
				id:   "msrv"
				run:  "awk -F '\"' '/rust-version/{ print \"version=\" $2 }' Cargo.toml >> $GITHUB_OUTPUT"
			}, {
				name: "Install ${{ steps.msrv.outputs.version }} Rust toolchain"
				uses: "dtolnay/rust-toolchain@master"
				with: toolchain: "${{ steps.msrv.outputs.version }}"
			}, {
				name: "Cache dependencies"
				uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
			}, {
				name: "Check packages and dependencies for errors"
				run:  "cargo check --locked"
			}]
		}

		workflow_status: {
			name:      "check workflow status"
			if:        "always()"
			"runs-on": "ubuntu-latest"
			needs: [
				"format",
				"lint",
				"msrv",
			]
			steps: [{
				name: "Check `stable / format` job status"
				run: """
					[[ \"${{ needs.format.result }}\" = \"success\" ]] && exit 0 || exit 1

					"""
			}, {
				name: "Check `stable / lint` job status"
				run: """
					[[ \"${{ needs.lint.result }}\" = \"success\" ]] && exit 0 || exit 1

					"""
			}, {
				name: "Check `msrv / compile` job status"
				run: """
					[[ \"${{ needs.msrv.result }}\" = \"success\" ]] && exit 0 || exit 1

					"""
			}]
		}
	}
}
