mod fixup;

use std::{
    env,
    error::Error,
    path::{Path, PathBuf},
};

use xshell::Shell;

type DynError = Box<dyn Error>;

fn main() -> Result<(), DynError> {
    let task = env::args().nth(1);
    match task {
        None => tasks::print_help(),
        Some(t) => match t.as_str() {
            "--help" => tasks::print_help(),
            "fixup" => tasks::fixup()?,
            "fixup.github-actions" => tasks::fixup_github_actions()?,
            "fixup.markdown" => tasks::fixup_markdown()?,
            "fixup.rust" => tasks::fixup_rust()?,
            "fixup.spelling" => tasks::fixup_spelling()?,
            invalid => return Err(format!("Invalid task name: {}", invalid).into()),
        },
    };
    Ok(())
}

pub mod tasks {
    use crate::fixup::{
        format_cue, format_markdown, format_rust, lint_rust, regenerate_ci_yaml, spellcheck,
    };
    use crate::DynError;

    pub fn fixup() -> Result<(), DynError> {
        fixup_spelling()?; // affects all file types; run this first
        fixup_github_actions()?;
        fixup_markdown()?;
        fixup_rust()
    }

    pub fn fixup_github_actions() -> Result<(), DynError> {
        format_cue()?;
        regenerate_ci_yaml()
    }

    pub fn fixup_markdown() -> Result<(), DynError> {
        format_markdown()
    }

    pub fn fixup_rust() -> Result<(), DynError> {
        lint_rust()?;
        format_rust()
    }

    pub fn fixup_spelling() -> Result<(), DynError> {
        spellcheck()
    }

    pub fn print_help() {
        println!(
            "
Usage: cargo xtask <task>

Description:
    Custom cargo commands for invoking developer tools that standardize
    processes and files within this project's repository.

Tasks:
    fixup                  Run all fixup xtasks, editing files in-place.
    fixup.markdown         Format Markdown files in-place.
    fixup.spelling         Fix common misspellings across all files in-place.
    fixup.github-actions   Format CUE files in-place and regenerate CI YAML files.
    fixup.rust             Fix lints and format Rust files in-place.
"
        );
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
