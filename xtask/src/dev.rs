use anyhow::Result;
use xshell::{cmd, Shell};

use crate::commands::cargo_cmd;
use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn install_rust_deps(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    cmd!(sh, "rustup toolchain add stable --component clippy").run()?;
    cmd!(sh, "rustup toolchain add nightly --component rustfmt").run()?;

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec![
            "install",
            "cargo-insta",
            "cargo-llvm-cov",
            "cargo-nextest",
            "cargo-watch",
        ];
        cmd.args(args).run()?;
    }

    Ok(())
}

pub fn test_with_snapshots(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["insta", "test", "--test-runner", "nextest", "--review"];
        cmd.args(args).run()?;
    }

    Ok(())
}

pub fn watch_clippy(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    println!("\nPress Ctrl-C to stop the program.");

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["watch", "--why", "-x", "clippy --locked --all-targets"];
        cmd.args(args).run()?;
    }

    Ok(())
}
