use std::env;

use anyhow::Result;

mod commands;
mod coverage;
mod dist;
mod fixup;
mod install;
mod utils;

const HELP: &str = "\
cargo xtask - helper scripts for running common project tasks

USAGE:
    cargo xtask [OPTIONS] [TASK]...

OPTIONS:
    -i, --ignore-missing   Ignores any missing tools; only warns
    -h, --help             Prints help information

TASKS:
    coverage               Generate and print a code coverage report summary
    coverage.html          Generate and open an HTML code coverage report
    dist                   Package project assets into distributable artifacts
    fixup                  Run all fixup xtasks, editing files in-place
    fixup.github-actions   Format CUE files in-place and regenerate CI YAML files
    fixup.markdown         Format Markdown files in-place
    fixup.rust             Fix lints and format Rust files in-place
    fixup.spelling         Fix common misspellings across all files in-place
    install                Install required Rust components and cargo dependencies
";

enum Task {
    Coverage,
    CoverageHtml,
    Dist,
    Fixup,
    FixupGithubActions,
    FixupMarkdown,
    FixupRust,
    FixupSpelling,
    Install,
}

pub struct Config {
    run_tasks: Vec<Task>,
    ignore_missing_commands: bool,
}

fn main() -> Result<()> {
    // print help when no arguments are given
    if env::args().len() == 1 {
        print!("{HELP}");
        std::process::exit(1);
    }

    let config = parse_args()?;
    for task in &config.run_tasks {
        match task {
            Task::Coverage => coverage::report_summary(&config)?,
            Task::CoverageHtml => coverage::html_report(&config)?,
            Task::Dist => dist::dist(&config)?,
            Task::Fixup => fixup::everything(&config)?,
            Task::FixupGithubActions => fixup::github_actions(&config)?,
            Task::FixupMarkdown => fixup::markdown(&config)?,
            Task::FixupRust => fixup::rust(&config)?,
            Task::FixupSpelling => fixup::spelling(&config)?,
            Task::Install => install::rust_dependencies(&config)?,
        }
    }

    Ok(())
}

fn parse_args() -> Result<Config> {
    use lexopt::prelude::*;

    // default config values
    let mut run_tasks = Vec::new();
    let mut ignore_missing_commands = false;

    let mut parser = lexopt::Parser::from_env();
    while let Some(arg) = parser.next()? {
        match arg {
            Short('h') | Long("help") => {
                print!("{HELP}");
                std::process::exit(0);
            }
            Short('i') | Long("ignore-missing") => {
                ignore_missing_commands = true;
            }
            Value(value) => {
                let value = value.string()?;
                let task = match value.as_str() {
                    "coverage" => Task::Coverage,
                    "coverage.html" => Task::CoverageHtml,
                    "dist" => Task::Dist,
                    "fixup" => Task::Fixup,
                    "fixup.github-actions" => Task::FixupGithubActions,
                    "fixup.markdown" => Task::FixupMarkdown,
                    "fixup.rust" => Task::FixupRust,
                    "fixup.spelling" => Task::FixupSpelling,
                    "install" => Task::Install,
                    value => {
                        anyhow::bail!("unknown task '{}'", value);
                    }
                };
                run_tasks.push(task);
            }
            _ => anyhow::bail!(arg.unexpected()),
        }
    }

    if run_tasks.is_empty() {
        anyhow::bail!("no task given");
    }

    Ok(Config {
        run_tasks,
        ignore_missing_commands,
    })
}
