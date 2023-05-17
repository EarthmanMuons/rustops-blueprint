use anyhow::Result;
use xshell::{cmd, Shell};

use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn rust_dependencies(_config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    cmd!(sh, "rustup component add clippy rustfmt").run()?;
    cmd!(sh, "cargo install cargo-insta cargo-llvm-cov cargo-nextest").run()?;
    Ok(())
}
