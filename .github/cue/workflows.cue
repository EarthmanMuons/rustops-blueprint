package workflows

import "encoding/yaml"

import "json.schemastore.org/github"

workflows: [...{
	filename: *"\(workflow.name).yml" | string
	workflow: github.#Workflow
}]

workflows: [
	{workflow: githubActions},
	{workflow: githubPages},
	{workflow: preloadCache},
	{workflow: rust},
	{workflow: wordsmith},
]

defaultBranch: "main"
defaultRunner: "ubuntu-latest"

_#pullRequestWorkflow: github.#Workflow & {
	concurrency: {
		group:                "${{ github.workflow }}-${{ github.head_ref || github.run_id }}"
		"cancel-in-progress": true
	}
}

_#useMergeQueue: _#pullRequestWorkflow & {
	name: string
	let workflowName = name

	on: {
		pull_request: branches: [defaultBranch]
		merge_group: types: ["checks_requested"]
	}

	jobs: merge_queue: _#job & {
		name:      "\(workflowName) workflow ready"
		needs:     github.#Workflow.#jobNeeds
		"runs-on": defaultRunner
		if:        "always()"
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

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  (github.#Workflow.jobs & {x: _}).x
_#step: ((_#job & {steps:            _}).steps & [_])[0]

_fileFilters: {
	"github-actions": [
		".github/**/*.yml",
		".github/cue/**/*.cue",
	]
	markdown: [
		{"added|modified": "**/*.md"},
	]
	rust: [
		"**/*.rs",
		"**/Cargo.*",
		".github/workflows/rust.yml",
	]
}

_#detectFileChanges: _#job & {
	name:      "detect file changes"
	"runs-on": defaultRunner
	permissions: "pull-requests": "read"
	outputs: {
		for filter, _ in _fileFilters {
			"\(filter)":       "${{ steps.filter.outputs.\(filter) }}"
			"\(filter)_files": "${{ steps.filter.outputs.\(filter)_files }}"
		}
	}
	steps: [
		_#checkoutCode & {with: "fetch-depth": 20},
		{
			name: "Filter changed repository files"
			uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
			id:   "filter"
			with: {
				"list-files": "shell"
				filters:      yaml.Marshal(_fileFilters)
			}
		},
	]
}
