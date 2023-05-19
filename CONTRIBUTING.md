# Contributing to RustOps Blueprint

Thank you for your interest in contributing to our project! This document will
guide you through the process. To maintain a respectful and welcoming community,
please adhere to the [Code of Conduct][CoC].

[CoC]: CODE_OF_CONDUCT.md

## Getting Started

RustOps Blueprint uses the GitHub [issue tracker][] to manage bugs and feature
requests. If you'd like to work on a specific issue, leave a comment, and we
will assign it to you. For general questions and open-ended conversations, use
the dedicated community [discussions][] space instead.

Please submit contributions through GitHub [pull requests][]. Each PR will be
reviewed by a core contributor (someone with permission to approve patches), and
either merged or provided with feedback for any required changes. _This process
applies to all contributions, including those from core contributors._

If your intended contribution is complex or requires discussion, open a new
[ideas discussion][] about the change before starting the work. We're more than
happy to mentor contributors and provide guidance or clarification when needed.

[issue tracker]: https://github.com/EarthmanMuons/rustops-blueprint/issues
[discussions]: https://github.com/EarthmanMuons/rustops-blueprint/discussions
[pull requests]: https://help.github.com/articles/using-pull-requests/
[ideas discussion]:
  https://github.com/EarthmanMuons/rustops-blueprint/discussions/new?category=ideas

## Reporting Bugs or Requesting Features

We appreciate your help in identifying issues or suggesting new features for our
project. To gather all relevant information and streamline the process, we use
built-in issue templates on GitHub.

Before opening a new issue, please search the [existing issues][issue tracker]
to see if your concern has already been reported or a similar feature has been
requested. This helps us avoid duplicate issues and ensures that we can focus on
addressing unique concerns effectively.

When reporting a bug or requesting a feature, please follow these steps:

1. Navigate to the [issue tracker][].
2. Click the "New issue" button.
3. Choose the appropriate template for your issue (bug report or feature
   request).
4. Fill out the template with all the necessary details to help us understand
   the issue or feature request.
5. Submit the issue.

### Issue Labels

Built-in issue templates will automatically apply some labels, but we also rely
on GitHub's [default labels][] to categorize issues and pull requests further.
Familiarize yourself with these labels to better understand the organization and
prioritization of tasks within the project.

[default labels]:
  https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/managing-labels#about-default-labels

## Setting Up a Development Environment

RustOps Blueprint follows the ["fork and pull"][] workflow model. After
[installing Rust][], fork this repository and create a local clone of your fork.

To facilitate tracking changes in the upstream repository, add it as a remote:

```
git remote add upstream https://github.com/EarthmanMuons/rustops-blueprint.git
```

["fork and pull"]: https://help.github.com/articles/fork-a-repo/
[installing Rust]: https://www.rust-lang.org/learn/get-started

### Install Rust Dependencies

The project is developed using the latest stable release of Rust, but it also
requires a couple of additional toolchain [components][]. We use the lint tool
[`clippy`][] for extra checks on common mistakes and stylistic choices, as well
as [`rustfmt`][] for automatic code formatting.

Additionally, our project utilizes [`cargo-insta`][] for snapshot testing,
[`cargo-llvm-cov`][] to generate code coverage reports, and [`cargo-nextest`][]
as an enhanced test runner. It displays each test's execution time by default,
and can help to identify performance outliers in the test suite.

[components]: https://rust-lang.github.io/rustup/concepts/components.html
[`clippy`]: https://doc.rust-lang.org/clippy/
[`rustfmt`]: https://github.com/rust-lang/rustfmt
[`cargo-insta`]: https://insta.rs/
[`cargo-llvm-cov`]: https://github.com/taiki-e/cargo-llvm-cov
[`cargo-nextest`]: https://nexte.st/

#### Automated Installation

We've provided an xtask script to automatically install all required toolchain
components and cargo dependencies. To use this, run the following command:

```
cargo xtask install
```

#### Manual Installation

If you prefer to install the required tools manually, or need more control over
the installation process, follow these steps:

1. Install the required toolchain components:

   ```
   rustup component add clippy rustfmt
   ```

2. Install the required cargo dependencies:

   ```
   cargo install cargo-insta cargo-llvm-cov cargo-nextest
   ```

### Install Additional Tools

To maintain consistency and avoid bikeshedding, our project also uses automated
tools to enforce formatting and style conventions for non-Rust files. Ensure
that you have the following tools installed:

- [actionlint][] for linting GitHub Actions workflow files
- [codespell][] for spell checking all files
- [CUE][] for generating and validating YAML files
- [Prettier][] for formatting Markdown files

[actionlint]: https://github.com/rhysd/actionlint
[codespell]: https://github.com/codespell-project/codespell
[CUE]: https://cuelang.org/
[Prettier]: https://prettier.io/

## Contribution Guidelines

- Adhere to the coding style conventions used in the project, which are enforced
  by the automated tools mentioned earlier. (Hint: Run `cargo xtask fixup` to
  edit repository files in-place and apply all automated fixes.)

- Write clear and concise [commit messages][].

- Update documentation as necessary.

- Follow the [Keep a Changelog][] format when updating the changelog.

- Ensure your changes are thoroughly tested. Our continuous integration (CI)
  pipeline extensively tests all pull requests, and to be merged, a PR must have
  no warnings or errors.

[commit messages]:
  https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/

## Testing Conventions

RustOps Blueprint follows standard Rust testing conventions, which includes:

- **Unit tests:** Located alongside the source code files they test. Unit tests
  focus on individual functions or modules and should be placed in the same
  file, usually at the bottom, under a `#[cfg(test)]` attribute and a
  `mod tests { ... }` block.

- **Integration tests:** Located in the top-level `tests/` directory.
  Integration tests cover the interaction between multiple components or the
  behavior of the whole system.

- **Snapshot tests:** We use [`cargo-insta`][] for maintaining snapshot tests.
  These tests compare the output of your code against a previously recorded
  "snapshot" to ensure consistent results. Follow the upstream documentation for
  creating and updating snapshots as needed.

When contributing, ensure that your changes are well-tested by including
appropriate unit, integration, and snapshot tests as necessary.

## Contribution Process

### 1. Create a new branch for your changes

Based on the `main` branch, create a new branch for your work:

```
git checkout -b your-feature-branch
```

### 2. Make and commit changes

Use the stacked commit approach, where each commit represents a single change,
including all applicable documentation, tests, and so on. This simplifies the
pull request review process and maintains a clean commit history.

### 3. Keep your branch up-to-date with the upstream repo

Regularly rebase your branch to stay current with the latest changes in the
upstream repository:

```
git fetch upstream
git rebase upstream/main
```

Resolve any conflicts that may occur during the rebase process.

### 4. Push your changes and create a pull request

When your changes are ready for review, push your branch to your fork:

```
git push -u origin your-feature-branch
```

Create a pull request on GitHub, comparing your fork's branch with the original
repository's `main` branch. If changes are requested, rewrite the branch rather
than adding commits on top, and then force push them to your repository. As you
update your PR and apply changes, mark each conversation as [resolved][].

Once your changes have been discussed and approved, we use GitHub [merge
queues][] to enforce the [not rocket science][] rule of software engineering,
ensuring that tests on the `main` branch always pass.

[resolved]:
  https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/commenting-on-a-pull-request#resolving-conversations
[merge queues]:
  https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/merging-a-pull-request-with-a-merge-queue
[not rocket science]: https://graydon2.dreamwidth.org/1597.html

## Useful Commands

There are some helpful [xtask][] scripts in the repository for running common
tasks and replicating CI jobs locally. You can view the details and available
commands by running:

```
cargo xtask --help
```

For example:

- Generate and open an HTML code coverage report

  ```
  cargo xtask coverage.html
  ```

[xtask]: https://github.com/matklad/cargo-xtask

Most other commands are the same as any standard Rust project:

- Lint the code

  ```
  cargo clippy
  ```

- Format the code

  ```
  cargo fmt
  ```

- Run all tests and doctests

  ```
  cargo nextest run --all-targets --all-features
  cargo test --doc
  ```

- Build and run the release version:

  ```
  cargo run --release --bin mybin
  ```
