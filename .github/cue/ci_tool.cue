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
command: "import-jsonschema": {
	getJSONSchema: http.Get & {
		// https://github.com/SchemaStore/schemastore/blob/master/src/schemas/json/github-workflow.json
		_commit: "5ffe36662a8fcab3c32e8fbca39c5253809e6913"
		request: body: ""
		url: "https://raw.githubusercontent.com/SchemaStore/schemastore/\(_commit)/src/schemas/json/github-workflow.json"
	}
	import: exec.Run & {
		_outpath: path.FromSlash("cue.mod/pkg/json.schemastore.org/github/github-workflow.cue", path.Unix)
		stdin:    getJSONSchema.response.body
		cmd:      "cue import -f -p github -l #Workflow: -o \(_outpath) jsonschema: -"
	}
}

// regenerate workflow yaml files from cue definitions
command: "regen-ci-yaml": {
	_dir:       path.FromSlash("../workflows", path.Unix)
	_donotedit: "This file is generated by .github/cue/ci_tool.cue; DO NOT EDIT!"

	ci: {
		remove: {
			glob: file.Glob & {
				glob: path.Join([_dir, "*.yml"])
			}
			for _, _filename in glob.files {
				"delete \(_filename)": file.RemoveAll & {
					path: _filename
				}
			}
		}
		for _w in workflows {
			"generate \(_w.filename)": file.Create & {
				$after: [ for v in remove {v}]
				filename: path.Join([_dir, _w.filename], path.Unix)
				contents: "# \(_donotedit)\n\n\(yaml.Marshal(_w.workflow))"
			}
		}
	}
}
