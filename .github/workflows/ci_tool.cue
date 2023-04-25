package workflows

import (
	"tool/file"
	"encoding/yaml"
)

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

command: genworkflows: {
	for w in workflows {
		"\(w.filename)": file.Create & {
			filename: w.filename
			contents: yaml.Marshal(w.workflow)
		}
	}
}
