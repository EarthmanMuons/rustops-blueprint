use std::{path::PathBuf, process::Command};

use crate::project_root;
use crate::DynError;

pub fn gen_workflows() -> Result<(), DynError> {
    println!("Generating GitHub Actions workflow YAML files from CUE definitions...");
    let status = Command::new("cue".to_string())
        .current_dir(cue_dir())
        .args(&["cmd", "genworkflows"])
        .status()?;
    if !status.success() {
        Err("`cue cmd genworkflows` failed.")?;
    }
    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}
