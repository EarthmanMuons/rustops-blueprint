package workflows

import "strings"

_sha1: =~"^[0-9a-fA-F]{40}$"

#pinned: S={
	string
	_parts:          strings.Split(S, "@")
	_hasTwoParts:    len(_parts) == 2 & true
	_hasSlash:       strings.Contains(_parts[0], "/") & true
	_refIsCommitSha: _parts[1] & _sha1
}

// all third-party actions must be pinned to a specific commit id
_#step: uses?: #pinned

// https://github.com/Swatinem/rust-cache/releases
_#cacheRust: _#step & {
	name: "Cache dependencies"
	uses: "Swatinem/rust-cache@6fd3edff6979b79f87531400ad694fb7f2c84b1f"

	// share the cache across all workflow jobs instead of keying on job_id 
	with: "shared-key": *"stable-\(defaultRunner)" | string
}

_#cargoCheck: _#step & {
	name: "Check packages and dependencies for errors"
	run:  "cargo check --locked"
}

// https://github.com/actions/checkout/releases
_#checkoutCode: _#step & {
	name: "Checkout source code"
	uses: "actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab"
}

// https://github.com/codespell-project/actions-codespell/releases
_#codespell: _#step & {
	name: "Check common misspellings"
	uses: "codespell-project/actions-codespell@22ff5a2e4b591290baf82d47c9feadac31c65441"
}

// https://github.com/dorny/paths-filter/releases
_#filterChanges: _#step & {
	name: "Filter changed repository files"
	uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
	id:   "filter"
}

// https://github.com/cue-lang/setup-cue/commits/main
_#installCue: _#step & {
	name: "Install CUE \(with.version)"
	uses: "cue-lang/setup-cue@0be332bb74c8a2f07821389447ba3163e2da3bfb"
	with: version: "v0.5.0"
}

// https://github.com/dtolnay/rust-toolchain/commits/master
_#installRust: _#step & {
	name: "Install \(with.toolchain) Rust toolchain"

	// NOTE: upstream does not tag releases, so this won't be updated by dependabot
	uses: "dtolnay/rust-toolchain@b44cb146d03e8d870c57ab64b80f04586349ca5d"
	with: {
		toolchain:   *"stable" | string
		components?: string
	}
}

// https://github.com/taiki-e/install-action/releases
_#installTool: _#step & {
	name: "Install \(with.tool)"
	uses: "taiki-e/install-action@a775aaf2e8ed709f76ee019cb77e39fc50613631"
	with: tool: string
}

// https://github.com/dorny/paths-filter/releases
_#pathsFilter: _#step & {
	name: "Filter changed repository files"
	uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
}

// https://github.com/creyD/prettier_action/releases
_#prettier: _#step & {
	name: "Check formatting"
	uses: "creyD/prettier_action@31355f8eef017f8aeba2e0bc09d8502b13dbbad1"
	with: prettier_version: "2.8.8"
}

_testRust: [
	_#installTool & {with: tool: "cargo-nextest"},
	_#step & {
		name: "Compile tests"
		run:  "cargo test --locked --no-run"
	},
	_#step & {
		name: "Run tests"
		run:  "cargo nextest run --locked --all-targets --all-features"
	},
	_#step & {
		name: "Run doctests"
		run:  "cargo test --locked --doc"
	},
]
