use std::path::PathBuf;
use xshell::{cmd, Shell};

use crate::project_root;
use crate::DynError;

pub fn generate_ci() -> Result<(), DynError> {
    let sh = Shell::new()?;
    sh.change_dir(cue_dir());
    eprintln!("$ cd {}", sh.current_dir().display());
    cmd!(sh, "cue cmd gen-ci").run()?;
    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}
