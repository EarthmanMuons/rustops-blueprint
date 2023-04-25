package workflows

import "json.schemastore.org/github"

workflows: [...{
	filename: string
	workflow: github.#Workflow
}]

// TODO: drop when cuelang.org/issue/390 is fixed.
// Declare definitions for sub-schemas
_#job:  ((github.#Workflow & {}).jobs & {x: _}).x
_#step: ((_#job & {steps:                   _}).steps & [_])[0]

workflows: [
	{
		filename: "check.yml"
		workflow: check
	},
	{
		filename: "docs.yml"
		workflow: docs
	},
	{
		filename: "test.yml"
		workflow: test
	},
]

_#checkoutCode: {
	_#step & {
		name: "Checkout source code"
		uses: "actions/checkout@v3"
	}
}
