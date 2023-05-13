use anyhow::Result;
use std::env;
use std::path::{Path, PathBuf};
use xshell::Shell;

mod fixup;

fn main() -> Result<()> {
    let task = env::args().nth(1);
    match task {
        None => tasks::print_help()?,
        Some(t) => match t.as_str() {
            "--help" => tasks::print_help()?,
            "fixup" => tasks::fixup()?,
            "fixup.github-actions" => tasks::fixup_github_actions()?,
            "fixup.markdown" => tasks::fixup_markdown()?,
            "fixup.rust" => tasks::fixup_rust()?,
            "fixup.spelling" => tasks::fixup_spelling()?,
            invalid => return Err(anyhow::anyhow!("Invalid task name: {}", invalid)),
        },
    };
    Ok(())
}

pub mod tasks {
    use crate::fixup::{format_cue, format_markdown, format_rust};
    use crate::fixup::{lint_cue, lint_rust};
    use crate::fixup::{regenerate_ci_yaml, spellcheck};
    use anyhow::Result;

    const HELP: &str = "\
NAME
    cargo xtask - helper scripts for running common project tasks

SYNOPSIS
    cargo xtask --help
    cargo xtask <COMMAND>

COMMANDS
    fixup                  Run all fixup xtasks, editing files in-place.
    fixup.markdown         Format Markdown files in-place.
    fixup.spelling         Fix common misspellings across all files in-place.
    fixup.github-actions   Format CUE files in-place and regenerate CI YAML files.
    fixup.rust             Fix lints and format Rust files in-place.
";

    pub fn fixup() -> Result<()> {
        fixup_spelling()?; // affects all file types; run this first
        fixup_github_actions()?;
        fixup_markdown()?;
        fixup_rust()
    }

    pub fn fixup_github_actions() -> Result<()> {
        lint_cue()?;
        format_cue()?;
        regenerate_ci_yaml()
    }

    pub fn fixup_markdown() -> Result<()> {
        format_markdown()
    }

    pub fn fixup_rust() -> Result<()> {
        lint_rust()?;
        format_rust()
    }

    pub fn fixup_spelling() -> Result<()> {
        spellcheck()
    }

    pub fn print_help() -> Result<()> {
        print!("{}", HELP);
        Ok(())
    }
}

pub fn project_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to find project root")
        .to_path_buf()
}

pub fn verbose_cd<P: AsRef<Path>>(sh: &Shell, dir: P) {
    sh.change_dir(dir);
    eprintln!(
        "\n$ cd {}{}",
        sh.current_dir().display(),
        std::path::MAIN_SEPARATOR
    );
}
