mod cue;

use std::{
    env,
    error::Error,
    path::{Path, PathBuf},
};

type DynError = Box<dyn Error>;

fn main() -> Result<(), DynError> {
    let task = env::args().nth(1);
    match task {
        None => tasks::print_help(),
        Some(t) => match t.as_str() {
            "--help" => tasks::print_help(),
            "gen-ci" => tasks::gen_ci()?,
            invalid => return Err(format!("Invalid task name: {}", invalid).into()),
        },
    };
    Ok(())
}

pub mod tasks {
    use crate::cue::generate_ci;
    use crate::DynError;

    pub fn gen_ci() -> Result<(), DynError> {
        generate_ci()
    }

    pub fn print_help() {
        println!(
            "
Usage: Run with `cargo xtask <task>`, eg. `cargo xtask gen-ci`.

    Tasks:
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
