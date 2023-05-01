use std::{path::PathBuf, process::Command};

use crate::project_root;
use crate::DynError;

pub fn generate_ci() -> Result<(), DynError> {
    println!("Regenerating GitHub Actions workflow YAML files from CUE definitions...");
    let status = Command::new("cue".to_string())
        .current_dir(cue_dir())
        .args(&["cmd", "gen-ci"])
        .status()?;
    if !status.success() {
        Err("`cue cmd gen-ci` failed.")?;
    }
    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}
