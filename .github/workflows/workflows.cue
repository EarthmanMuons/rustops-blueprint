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
_borsBranches: ["staging", "trying"]
defaultPushBranches: list.Concat([[defaultBranch], _borsBranches])

defaultRunner: "ubuntu-latest"

// https://bors.tech/documentation/getting-started/
_#borsWorkflow: github.#Workflow & {
	name: string
	let workflowName = name

	jobs: {
		"bors": _#job & {
			name: "bors needs met for \(workflowName)"
			// TODO: ensure needs can't be empty
			needs: github.#Workflow.#jobNeeds
			if:    "always()"
			steps: [
				for jobId in needs {
					name: "Check status of job_id: \(jobId)"
					run:  "[[ \"${{ needs.\(jobId).result }}\" = \"success\" ]] && exit 0 || exit 1"
				},
			]
		}
	}
}

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  (github.#Workflow.jobs & {x: _}).x
_#step: ((_#job & {steps:            _}).steps & [_])[0]

_#defaultJobs: github.#Workflow.jobs & {
	[string]: "runs-on": defaultRunner
}

_#checkoutCode: _#step & {
	name: "Checkout source code"
	uses: "actions/checkout@v3"
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
