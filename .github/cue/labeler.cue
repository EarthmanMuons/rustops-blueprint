package workflows

labeler: _#pullRequestWorkflow & {
	name: "labeler"

	on: pull_request_target: types: ["opened", "synchronize", "reopened"]

	jobs: label_pr: {
		name: "label pr"
		permissions: {
			contents:        "read"
			"pull-requests": "write"
		}
		"runs-on": defaultRunner
		steps: [
			_#labeler,
		]
	}
}
