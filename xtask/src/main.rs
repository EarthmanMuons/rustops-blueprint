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
            "gen.workflows" => tasks::genworkflows()?,
            invalid => return Err(format!("Invalid task name: {}", invalid).into()),
        },
    };
    Ok(())
}

pub mod tasks {
    use crate::cue::gen_workflows;
    use crate::DynError;

    pub fn genworkflows() -> Result<(), DynError> {
        gen_workflows()
    }

    pub fn print_help() {
        println!(
            "
Usage: Run with `cargo xtask <task>`, eg. `cargo xtask gen.workflows`.

    Tasks:
        gen.workflows: Generate GitHub Actions workflow YAML files from CUE definitions.
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
