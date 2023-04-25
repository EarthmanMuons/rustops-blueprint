package workflows

import (
	"encoding/yaml"
	"path"
	"tool/exec"
	"tool/file"
	"tool/http"
)

// vendor a CUE-imported version of the JSONSchema that defines
// GitHub Actions workflows into the main module's cue.mod/pkg
command: importjsonschema: {
	getJSONSchema: http.Get & {
		// https://github.com/SchemaStore/schemastore/blob/master/src/schemas/json/github-workflow.json
		_commit: "5ffe36662a8fcab3c32e8fbca39c5253809e6913"
		request: body: ""
		url: "https://raw.githubusercontent.com/SchemaStore/schemastore/\(_commit)/src/schemas/json/github-workflow.json"
	}
	import: exec.Run & {
		_outpath: path.FromSlash("../cue.mod/pkg/json.schemastore.org/github/github-workflow.cue", "unix")
		stdin:    getJSONSchema.response.body
		cmd:      "cue import -f -p github -l #Workflow: -o \(_outpath) jsonschema: -"
	}
}

command: genworkflows: {
	for w in workflows {
		"\(w.filename)": file.Create & {
			filename: w.filename
			contents: yaml.Marshal(w.workflow)
		}
	}
}
