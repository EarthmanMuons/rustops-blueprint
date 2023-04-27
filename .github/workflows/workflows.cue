package workflows

import "json.schemastore.org/github"

import "list"

workflows: [...{
	filename: string
	workflow: github.#Workflow
}]

workflows: [
	{
		filename: "github-actions.yml"
		workflow: githubActions
	},
	{
		filename: "github-pages.yml"
		workflow: githubPages
	},
	{
		filename: "rust.yml"
		workflow: rust
	},
]

defaultBranch: "main"
borsBranches: ["staging", "trying"]

defaultRunner: "ubuntu-latest"

_#pullRequestWorkflow: github.#Workflow & {
	concurrency: {
		group:                "${{ github.workflow }}-${{ github.head_ref || github.run_id }}"
		"cancel-in-progress": true
	}
}

// https://bors.tech/documentation/getting-started/
_#borsWorkflow: _#pullRequestWorkflow & {
	name: string
	let workflowName = name

	on: {
		pull_request: branches: [defaultBranch]
		push: branches: list.Concat([[defaultBranch], borsBranches])
	}

	jobs: {
		"bors": _#job & {
			name: "bors needs met for \(workflowName)"
			// TODO: ensure needs can't be empty
			needs:     github.#Workflow.#jobNeeds
			"runs-on": defaultRunner
			"if":      "always()"
			steps: [
				for jobId in needs {
					name: "Check status of job_id: \(jobId)"
					run:  """
						RESULT="${{ needs.\(jobId).result }}";
						if [[ $RESULT == "success" || $RESULT == "skipped" ]]; then
						    exit 0
						else
						    echo "***"
						    echo "Error: The required job did not pass."
						    exit 1
						fi
						"""
				},
			]
		}
	}
}

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  (github.#Workflow.jobs & {x: _}).x
_#step: ((_#job & {steps:            _}).steps & [_])[0]

_#changes: _#job & {
	name:      "detect repo changes"
	"runs-on": defaultRunner
	permissions: "pull-requests": "read"
	outputs: {
		"github-actions": "${{ steps.filter.outputs.github-actions }}"
		"rust":           "${{ steps.filter.outputs.rust }}"
	}
	steps: [
		_#checkoutCode & {with: "fetch-depth": 20},
		{
			name: "Filter changed repository files"
			uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
			id:   "filter"
			with: filters: """
				github-actions:
				  - '.github/**/*.cue'
				  - '.github/**/*.yml'
				rust:
				  - '**/*.rs'
				  - '**/Cargo.*'
				  - '.github/workflows/rust.yml'
				"""
		},
	]
}

_#checkoutCode: _#step & {
	name: "Checkout source code"
	uses: "actions/checkout@v3"
}

_#filterChanges: _#step & {
	name: "Filter changed repository files"
	uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
	id:   "filter"
}

_#installCue: _#step & {
	name: "Install CUE \(with.version)"
	uses: "cue-lang/setup-cue@0be332bb74c8a2f07821389447ba3163e2da3bfb"
	with: version: "v0.5.0"
}

_#installRust: _#step & {
	name: "Install \(with.toolchain) Rust toolchain"
	uses: "dtolnay/rust-toolchain@b44cb146d03e8d870c57ab64b80f04586349ca5d"
	with: toolchain:   string | *"stable"
	with: components?: string
}

_#cacheRust: _#step & {
	name: "Cache dependencies"
	uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"
}

_#cargoCheck: _#step & {
	{
		name: "Check packages and dependencies for errors"
		run:  "cargo check --locked"
	}
}
