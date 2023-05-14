use anyhow::Result;
use xshell::{cmd, Shell};

use crate::utils::{project_root, verbose_cd};

pub fn rust_dependencies() -> Result<()> {
    let sh = Shell::new()?;
    let root = project_root();
    verbose_cd(&sh, &root);

    cmd!(sh, "rustup component add clippy rustfmt").run()?;
    cmd!(sh, "cargo install cargo-insta cargo-nextest").run()?;
    Ok(())
}
