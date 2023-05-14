use std::path::PathBuf;

use anyhow::Result;
use xshell::{cmd, Shell};

use crate::utils::{find_files, project_root, to_relative_paths, verbose_cd};

pub fn everything() -> Result<()> {
    spelling()?; // affects all file types; run this first
    github_actions()?;
    markdown()?;
    rust()?;
    Ok(())
}

pub fn spelling() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());
    cmd!(sh, "codespell --write-changes").run()?;
    Ok(())
}

pub fn markdown() -> Result<()> {
    format_markdown()?;
    Ok(())
}

fn format_markdown() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let markdown_files = find_files(sh.current_dir(), "md")?;
    let relative_paths = to_relative_paths(markdown_files, sh.current_dir());
    cmd!(sh, "prettier --prose-wrap always --write")
        .args(relative_paths)
        .run()?;

    Ok(())
}

pub fn rust() -> Result<()> {
    lint_rust()?;
    format_rust()?;
    Ok(())
}

fn lint_rust() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());
    cmd!(
        sh,
        "cargo fix --allow-no-vcs --all-features --edition-idioms"
    )
    .run()?;
    cmd!(
        sh,
        "cargo clippy --all-targets --all-features --fix --allow-no-vcs"
    )
    .run()?;
    cmd!(
        sh,
        "cargo clippy --all-targets --all-features -- -D warnings"
    )
    .run()?;
    Ok(())
}

fn format_rust() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());
    cmd!(sh, "cargo fmt").run()?;
    Ok(())
}

pub fn github_actions() -> Result<()> {
    lint_cue()?;
    format_cue()?;
    regenerate_ci_yaml()?;
    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}

fn lint_cue() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());
    cmd!(sh, "cue vet --concrete").run()?;
    Ok(())
}

fn format_cue() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());
    cmd!(sh, "cue fmt --simplify").run()?;
    Ok(())
}

fn regenerate_ci_yaml() -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());
    cmd!(sh, "cue cmd regen-ci-yaml").run()?;
    Ok(())
}
