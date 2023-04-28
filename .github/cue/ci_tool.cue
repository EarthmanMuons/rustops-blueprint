package workflows

import (
	"encoding/yaml"
	"path"
	"tool/exec"
	"tool/file"
	"tool/http"
)

// vendor a cue-imported version of the jsonschema that defines
// github actions workflows into the main module's cue.mod/pkg
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

// clear out any existing workflow yaml files
command: clearworkflows: {
	list: file.Glob & {
		glob: "../workflows/*.yml"
	}

	for _, filepath in list.files {
		(filepath): {
			remove: exec.Run & {
				cmd: "rm \(filepath)"
			}
		}
	}
}

// generate workflow yaml files from cue definitions
command: genworkflows: {
	clear: exec.Run & {
		cmd: "cue cmd clearworkflows"
	}

	for w in workflows {
		"\(w.filename)": file.Create & {
			$dep:     clear.$done
			filename: path.FromSlash("../workflows/\(w.filename)", "unix")
			contents: yaml.Marshal(w.workflow)
		}
	}
}
