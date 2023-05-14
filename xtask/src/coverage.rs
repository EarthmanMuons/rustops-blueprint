use std::fs;

use anyhow::{Context, Result};
use xshell::{cmd, Shell};

use crate::utils::{find_files, project_root, verbose_cd};

pub fn html_report() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    cmd!(sh, "cargo test --tests")
        .env("CARGO_INCREMENTAL", "0")
        .env("RUSTFLAGS", "-C instrument-coverage")
        .env("LLVM_PROFILE_FILE", "default_%m_%p.profraw")
        .run()?;

    let options = [
        "--binary-path",
        "./target/debug/",
        "--output-types",
        "html",
        "--output-path",
        "./target/debug/coverage/",
        "--source-dir",
        ".",
        "--ignore-not-existing",
        "--ignore",
        "xtask/*",
        "--branch",
    ];
    cmd!(sh, "grcov {options...} .").run()?;

    let profile_files = find_files(sh.current_dir(), "profraw")?;
    if !profile_files.is_empty() {
        eprintln!("Cleaning up LLVM profile files");
        for file in profile_files {
            fs::remove_file(&file)?;
        }
    }

    let report = project_root().join("target/debug/coverage/index.html");
    eprintln!("Opening {}", report.display());
    open::that(report).context("opening coverage report")?;
    Ok(())
}
