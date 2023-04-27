package workflows

githubActions: _#borsWorkflow & {
	name: "github-actions"

	on: {
		pull_request: branches: [defaultBranch]
		push: branches: defaultPushBranches
	}

	concurrency: {
		group:                "${{ github.workflow }}-${{ github.head_ref || github.run_id }}"
		"cancel-in-progress": true
	}

	env: CARGO_TERM_COLOR: "always"

	jobs: _#defaultJobs & {
		cue: {
			name: "cue / vet"
			steps: [
				_#checkoutCode,
				_#installCue,
				{
					name:                "Validate CUE files"
					"working-directory": ".github/workflows"
					run:                 "cue vet -c"
				},
				{
					name:                "Regenerate YAML from CUE"
					"working-directory": ".github/workflows"
					run:                 "cue cmd genworkflows"
				},
				{
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

		bors: needs: [
			"cue",
		]
	}
}
