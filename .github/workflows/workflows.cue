package workflows

import "json.schemastore.org/github"

workflows: [...{
	filename: string
	workflow: github.#Workflow
}]

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
