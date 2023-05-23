package workflows

wordsmith: _#useMergeQueue & {
	name: "wordsmith"

	env: CARGO_TERM_COLOR: "always"

	jobs: {
		changes: _#detectFileChanges

		markdown_format: {
			name: "markdown / format"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "github.event_name == 'pull_request' && needs.changes.outputs.markdown == 'true'"
			steps: [
				_#checkoutCode,
				_#prettier & {
					with: prettier_options: """
						--check --color --prose-wrap always ${{ needs.changes.outputs.markdown_files }}
						"""
				},
			]
		}

		spell_check: {
			name: "spell check"
			needs: ["changes"]
			"runs-on": defaultRunner
			if:        "github.event_name == 'pull_request'"
			steps: [
				_#checkoutCode,
				_#typos,
			]
		}

		merge_queue: needs: [
			"changes",
			"markdown_format",
			"spell_check",
		]
	}
}
