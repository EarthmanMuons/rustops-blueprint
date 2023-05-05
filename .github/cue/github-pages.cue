package workflows

githubPages: {
	name: "github-pages"

	on: {
		push: {
			branches: [defaultBranch]
			paths: [
				"!.github/**",
				".github/workflows/github-pages.yml",
				"**.rs",
			]
		}

		// Allow manually running this workflow.
		workflow_dispatch: null
	}

	// Allow only one concurrent deployment, skipping runs queued between the run in-
	// progress and latest queued. However, do NOT cancel in-progress runs as we want
	// to allow these production deployments to complete.
	concurrency: {
		group:                "${{ github.workflow }}-${{ github.ref }}"
		"cancel-in-progress": false
	}

	jobs: {
		build: {
			name:      "build / stable"
			"runs-on": defaultRunner
			env: CARGO_TERM_COLOR: "always"
			steps: [
				_#checkoutCode,
				_#installRust & {with: toolchain: "nightly"},
				{
					name: "Build docs"
					env: RUSTDOCFLAGS: "--enable-index-page -Z unstable-options"
					run: "cargo doc --no-deps"
				},
				{
					name: "Upload github-pages artifact"
					uses: "actions/upload-pages-artifact@v1"
					with: path: "target/doc"
				},
			]
		}

		deploy: {
			name: "deploy / github-pages"
			permissions: {
				"id-token": "write"
				pages:      "write"
			}
			needs:     "build"
			"runs-on": defaultRunner
			environment: {
				name: "github-pages"
				url:  "${{ steps.deployment.outputs.page_url }}"
			}
			steps: [
				{
					name: "Deploy to GitHub Pages"
					id:   "deployment"
					uses: "actions/deploy-pages@v2"
				},
			]
		}
	}
}
