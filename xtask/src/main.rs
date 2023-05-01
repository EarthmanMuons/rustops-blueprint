mod cue;
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
            "fixup.markdown" => tasks::fixup_markdown()?,
            "gen-ci" => tasks::gen_ci()?,
            invalid => return Err(format!("Invalid task name: {}", invalid).into()),
        },
    };
    Ok(())
}

pub mod tasks {
    use crate::cue::generate_ci;
    use crate::fixup::format_markdown;
    use crate::DynError;

    pub fn fixup_markdown() -> Result<(), DynError> {
        format_markdown()
    }

    pub fn gen_ci() -> Result<(), DynError> {
        generate_ci()
    }

    pub fn print_help() {
        println!(
            "
Usage: Run with `cargo xtask <task>`, eg. `cargo xtask gen-ci`.

    Tasks:
        fixup.markdown: Format Markdown files in-place. (Beware!)
        gen-ci: Regenerate GitHub Actions workflow YAML files from CUE definitions.
"
        );
    }
}

pub fn project_root() -> PathBuf {
    Path::new(&env!("CARGO_MANIFEST_DIR"))
        .ancestors()
        .nth(1)
        .unwrap()
        .to_path_buf()
}

pub fn verbose_cd<P: AsRef<Path>>(sh: &Shell, dir: P) {
    sh.change_dir(dir);
    eprintln!(
        "$ cd {}{}",
        sh.current_dir().display(),
        std::path::MAIN_SEPARATOR
    );
}
