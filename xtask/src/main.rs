use std::env;

use anyhow::Result;

mod coverage;
mod fixup;
mod install;
mod utils;

const HELP: &str = "\
NAME
    cargo xtask - helper scripts for running common project tasks

SYNOPSIS
    cargo xtask --help
    cargo xtask [COMMAND...]

COMMANDS
    coverage               Generate and print a code coverage report summary.
    coverage.html          Generate and open an HTML code coverage report.
    fixup                  Run all fixup xtasks, editing files in-place.
    fixup.github-actions   Format CUE files in-place and regenerate CI YAML files.
    fixup.markdown         Format Markdown files in-place.
    fixup.rust             Fix lints and format Rust files in-place.
    fixup.spelling         Fix common misspellings across all files in-place.
    install                Install required Rust components and cargo dependencies.
";

fn main() -> Result<()> {
    use lexopt::prelude::*;

    // print help when no arguments are given
    if env::args().len() == 1 {
        print!("{}", HELP);
        std::process::exit(1);
    }

    let mut parser = lexopt::Parser::from_env();
    while let Some(arg) = parser.next()? {
        match arg {
            Short('h') | Long("help") => {
                print!("{}", HELP);
                std::process::exit(0);
            }
            Value(value) => {
                let value = value.string()?;
                match value.as_str() {
                    "coverage" => coverage::report_summary()?,
                    "coverage.html" => coverage::html_report()?,
                    "fixup" => fixup::everything()?,
                    "fixup.github-actions" => fixup::github_actions()?,
                    "fixup.markdown" => fixup::markdown()?,
                    "fixup.rust" => fixup::rust()?,
                    "fixup.spelling" => fixup::spelling()?,
                    "install" => install::rust_dependencies()?,
                    value => {
                        anyhow::bail!("unknown command '{}'", value);
                    }
                }
            }
            _ => anyhow::bail!(arg.unexpected()),
        }
    }

    Ok(())
}
