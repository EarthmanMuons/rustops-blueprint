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
			if:        "${{ needs.changes.outputs.markdown == 'true' }}"
			steps: [
				_#checkoutCode,
				_#prettier & {
					with: prettier_options: """
						--check --color --prose-wrap always ${{ needs.changes.outputs.markdown_files }}
						"""
				},
			]
		}

		spellcheck: {
			name: "spellcheck"
			needs: ["changes"]
			"runs-on": defaultRunner
			steps: [
				_#checkoutCode,
				_#codespell,
			]
		}

		merge_queue: needs: [
			"markdown_format",
			"spellcheck",
		]
	}
}
