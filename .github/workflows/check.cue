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
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "clippy,rustfmt"},
				{
					name: "Cache dependencies"
					uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
				}, {
					name: "Check formatting"
					run:  "cargo fmt --check"
				},
			]
		}

		lint: {
			name:      "stable / lint"
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				_#installRust & {with: components: "clippy,rustfmt"},
				{
					name: "Cache dependencies"
					uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
				}, {
					name: "Check lints"
					run:  "cargo clippy -- -D warnings"
				},
			]
		}

		// Minimum Supported Rust Version
		msrv: {
			name:      "msrv / compile"
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Get MSRV from package metadata"
					id:   "msrv"
					run:  "awk -F '\"' '/rust-version/{ print \"version=\" $2 }' Cargo.toml >> $GITHUB_OUTPUT"
				},
				_#installRust & {with: toolchain: "${{ steps.msrv.outputs.version }}"},
				{
					name: "Cache dependencies"
					uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
				},
				{
					name: "Check packages and dependencies for errors"
					run:  "cargo check --locked"
				},
			]
		}

		cue: {
			name:      "cue / vet"
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Install CUE"
					uses: "cue-lang/setup-cue@0be332bb74c8a2f07821389447ba3163e2da3bfb"
					with: version: "v0.5.0"
				}, {
					name:                "Validate CUE files"
					"working-directory": ".github/workflows"
					run:                 "cue vet -c"
				}, {
					name:                "Regenerate YAML from CUE"
					"working-directory": ".github/workflows"
					run:                 "cue cmd genworkflows"
				}, {
					name: "Check if CUE and YAML are in sync"
					run: """
						if git diff --quiet HEAD --; then
						    echo 'CUE and YAML files are in sync; the working tree is clean.'
						else
						    git diff --color --patch-with-stat HEAD --
						    echo "***"
						    echo 'Error: CUE and YAML files are out of sync; the working tree is dirty.'
						    echo 'Run `cue cmd genworkflows` locally to regenerate the YAML from CUE.'
						    exit 1
						fi
						"""
				},
			]
		}

		workflow_status: {
			name:      "check workflow status"
			if:        "always()"
			"runs-on": "ubuntu-latest"
			needs: [
				"format",
				"lint",
				"msrv",
				"cue",
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
			}, {
				name: "Check `cue / vet` job status"
				run: """
					[[ \"${{ needs.cue.result }}\" = \"success\" ]] && exit 0 || exit 1
					"""
			}]
		}
	}
}
