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

## Setting Up a Development Environment

RustOps Blueprint follows the ["fork and pull"][] workflow model. After
[installing Rust][], fork this repository and create a local clone of your fork.

To facilitate tracking changes in the upstream repository, add it as a remote:

```
git remote add upstream https://github.com/EarthmanMuons/rustops-blueprint.git
```

["fork and pull"]: https://help.github.com/articles/fork-a-repo/
[installing Rust]: https://www.rust-lang.org/learn/get-started

### Install Rust Components

The project is developed using the latest stable release of Rust, but it also
requires a few additional toolchain [components][]. We use the lint tool
`clippy` for extra checks on common mistakes and stylistic choices, as well as
`rustfmt` for automatic code formatting. Install both components for your
current Rust toolchain using `rustup`:

```
rustup component add clippy rustfmt
```

Additionally, our project utilizes [`cargo-insta`](https://insta.rs/) for
snapshot testing, and we recommend [`cargo-nextest`](https://nexte.st/) as an
enhanced test runner. It displays each test's execution time by default, and can
help to identify performance outliers in the test suite. Install both tools via
`cargo`:

```
cargo install cargo-insta cargo-nextest
```

[components]: https://rust-lang.github.io/rustup/concepts/components.html

### Install Additional Tools

To maintain consistency and avoid bikeshedding, our project also uses automated
tools to enforce formatting and style conventions for non-Rust files. Ensure
that you have the following tools installed:

- [codespell](https://github.com/codespell-project/codespell) for spell checking
  all files
- [CUE](https://cuelang.org/) for generating and validating YAML files
- [Prettier](https://prettier.io/) for formatting Markdown files

## Contribution Guidelines

- Adhere to the coding style conventions used in the project, which are enforced
  by the automated tools mentioned earlier. (Hint: Run `cargo xtask fixup` to
  edit repository files in-place and apply all automated fixes.)

- Write clear and concise [commit messages][].

- Update documentation as necessary.

- Follow the [Keep a Changelog][] format when updating the changelog.

- Ensure your changes are thoroughly tested.

[commit messages]:
  https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/

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
than adding commits on top, and then force push them to your repository.

Once your changes have been discussed and approved, we use GitHub [merge
queues][] to enforce the [not rocket science][] rule of software engineering,
ensuring that tests on the `main` branch always pass.

[merge queues]:
  https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/incorporating-changes-from-a-pull-request/merging-a-pull-request-with-a-merge-queue
[not rocket science]: https://graydon2.dreamwidth.org/1597.html

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

## Useful Commands

There are some helpful [xtask][] scripts in the repository for running common
tasks. You can view the details by running:

```
cargo xtask --help
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
