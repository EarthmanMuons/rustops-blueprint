use anyhow::Result;
use xshell::{cmd, Shell};

use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn html_report(_config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());
    cmd!(
        sh,
        "cargo llvm-cov nextest --ignore-filename-regex xtask --open"
    )
    .run()?;
    Ok(())
}

pub fn report_summary(_config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());
    cmd!(sh, "cargo llvm-cov nextest --ignore-filename-regex xtask").run()?;
    Ok(())
}
