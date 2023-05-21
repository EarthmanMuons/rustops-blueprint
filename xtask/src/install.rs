use anyhow::Result;
use xshell::{cmd, Shell};

use crate::commands::cargo_cmd;
use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn rust_dependencies(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    cmd!(sh, "rustup component add clippy rustfmt").run()?;

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["install", "cargo-insta", "cargo-llvm-cov", "cargo-nextest"];
        cmd.args(args).run()?;
    }

    Ok(())
}
