use anyhow::{Context, Result};
use xshell::{cmd, Shell};

use crate::utils::{project_root, verbose_cd};

pub fn html_report() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let temp_dir = sh.create_temp_dir().context("allocating temp_dir")?;
    let temp_dir_path = temp_dir.path();

    cmd!(sh, "cargo test --tests")
        .env("CARGO_INCREMENTAL", "0")
        .env("RUSTFLAGS", "-C instrument-coverage")
        .env(
            "LLVM_PROFILE_FILE",
            temp_dir_path.join("default_%m_%p.profraw"),
        )
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
        "--branch",
    ];
    cmd!(sh, "grcov {options...} {temp_dir_path}").run()?;

    let report = project_root().join("target/debug/coverage/index.html");
    eprintln!("Opening {}", report.display());
    open::that(report).context("opening coverage report")?;

    Ok(())
}
