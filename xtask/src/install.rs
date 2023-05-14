use anyhow::Result;
use xshell::{cmd, Shell};

use crate::utils::{project_root, verbose_cd};

pub fn rust_dependencies() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    cmd!(sh, "rustup component add clippy llvm-tools-preview rustfmt").run()?;
    cmd!(sh, "cargo install cargo-insta cargo-nextest grcov").run()?;
    Ok(())
}
