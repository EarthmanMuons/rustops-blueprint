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

// https://github.com/raven-actions/actionlint/releases
_#actionlint: _#step & {
	name: "Check lints"
	uses: "raven-actions/actionlint@d6c9e3222b489401880e866bc6715049773b63a3"
	with: "group-result": false
}

// https://github.com/Swatinem/rust-cache/releases
_#cacheRust: _#step & {
	name: "Cache dependencies"
	uses: "Swatinem/rust-cache@988c164c3d0e93c4dbab36aaf5bbeb77425b2894"

	// share the cache across all workflow jobs instead of keying on job_id 
	with: "shared-key": *"stable-\(defaultRunner)" | string
	"timeout-minutes": 5
}

_#cargoCheck: _#step & {
	name: "Check packages and dependencies for errors"
	run:  "cargo check --locked --all-targets"
}

// https://github.com/actions/checkout/releases
_#checkoutCode: _#step & {
	name: "Checkout source code"
	uses: "actions/checkout@8e5e7e5ab8b370d6c329ec480221332ada57f0ab"
}

// https://github.com/actions/deploy-pages/releases
_#deployPages: _#step & {
	id:   "deployment"
	name: "Deploy to GitHub Pages"
	uses: "actions/deploy-pages@af48cf94a42f2c634308b1c9dc0151830b6f190a"
}

// https://github.com/dorny/paths-filter/releases
_#filterChanges: _#step & {
	id:   "filter"
	name: "Filter changed repository files"
	uses: "dorny/paths-filter@4512585405083f25c027a35db413c2b3b9006d50"
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
	uses: "taiki-e/install-action@1d74f337f279f52e54c352ebe5b96eaa36c948d3"
	with: tool: string
}

// https://github.com/actions/labeler/releases
_#labeler: _#step & {
	name: "Label pull request based on paths of changed files"
	uses: "actions/labeler@9fcb2c2f5584144ca754f8bfe8c6f81e77753375"
	with: dot: true
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

_setupMsrv: [
	{
		id:   "msrv"
		name: "Get MSRV from package metadata"
		run:  "awk -F '\"' '/rust-version/{ print \"version=\" $2 }' Cargo.toml >> \"$GITHUB_OUTPUT\""
	},
	_#installRust & {with: toolchain: "${{ steps.msrv.outputs.version }}"},
	_#installRust & {with: toolchain: "nightly"},
	{
		name: "Resolve minimal dependency versions instead of maximum"
		run:  "cargo +nightly update -Z direct-minimal-versions"
	},
	{
		name: "Set override to MSRV Rust"
		run:  "rustup override set ${{ steps.msrv.outputs.version }}"
	},
]

_testRust: [
	_#installTool & {with: tool: "cargo-nextest"},
	_#step & {
		name: "Compile tests"
		run:  "cargo test --locked --no-run"
	},
	_#step & {
		name: "Run tests"
		run:  "cargo nextest run --locked --all-targets"
	},
	_#step & {
		name: "Run doctests"
		run:  "cargo test --locked --doc"
	},
]

// https://github.com/crate-ci/typos/releases
_#typos: _#step & {
	name: "Check common misspellings"
	uses: "crate-ci/typos@38a1b194811847c93a72ab95f06d55b33806a160"
}

// https://github.com/actions/upload-pages-artifact/releases
_#uploadPagesArtifact: _#step & {
	name: "Upload github-pages artifact"
	uses: "actions/upload-pages-artifact@64bcae551a7b18bcb9a09042ddf1960979799187"
	with: path: string
}
