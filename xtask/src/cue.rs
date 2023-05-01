use std::path::PathBuf;
use xshell::{cmd, Shell};

use crate::{project_root, verbose_cd, DynError};

pub fn generate_ci() -> Result<(), DynError> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());
    cmd!(sh, "cue cmd gen-ci").run()?;
    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}
