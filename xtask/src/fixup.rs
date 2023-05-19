use std::path::PathBuf;

use anyhow::Result;
use xshell::Shell;

use crate::commands::{actionlint_cmd, cargo_cmd, codespell_cmd, cue_cmd, prettier_cmd};
use crate::utils::{find_files, project_root, to_relative_paths, verbose_cd};
use crate::Config;

pub fn everything(config: &Config) -> Result<()> {
    spelling(config)?; // affects all file types; run this first
    github_actions(config)?;
    markdown(config)?;
    rust(config)?;
    Ok(())
}

pub fn spelling(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = codespell_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["--write-changes"];
        cmd.args(args).run()?;
    }

    Ok(())
}

pub fn github_actions(config: &Config) -> Result<()> {
    lint_cue(config)?;
    format_cue(config)?;
    regenerate_ci_yaml(config)?;
    lint_workflows(config)?;
    Ok(())
}

pub fn markdown(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = prettier_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["--prose-wrap", "always", "--write"];
        let markdown_files = find_files(sh.current_dir(), "md")?;
        let relative_paths = to_relative_paths(markdown_files, sh.current_dir());
        cmd.args(args).args(relative_paths).run()?;
    }

    Ok(())
}

pub fn rust(config: &Config) -> Result<()> {
    lint_rust(config)?;
    format_rust(config)?;
    Ok(())
}

fn lint_cue(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());

    let cmd_option = cue_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["vet", "--concrete"];
        cmd.args(args).run()?;
    }

    Ok(())
}

fn format_cue(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());

    let cmd_option = cue_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["fmt", "--simplify"];
        cmd.args(args).run()?;
    }

    Ok(())
}

fn regenerate_ci_yaml(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, cue_dir());

    let cmd_option = cue_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["cmd", "regen-ci-yaml"];
        cmd.args(args).run()?;
    }

    Ok(())
}

fn cue_dir() -> PathBuf {
    project_root().join(".github/cue")
}

fn lint_workflows(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = actionlint_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        cmd.run()?;
    }

    Ok(())
}

fn lint_rust(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh)?;
    if let Some(_cmd) = cmd_option {
        let args = vec![
            "fix",
            "--allow-no-vcs",
            "--all-features",
            "--edition-idioms",
        ];
        cargo_cmd(config, &sh)?.unwrap().args(args).run()?;

        let args = vec![
            "clippy",
            "--all-targets",
            "--all-features",
            "--fix",
            "--allow-no-vcs",
        ];
        cargo_cmd(config, &sh)?.unwrap().args(args).run()?;

        let args = vec![
            "clippy",
            "--all-targets",
            "--all-features",
            "--",
            "-D",
            "warnings",
        ];
        cargo_cmd(config, &sh)?.unwrap().args(args).run()?;
    }

    Ok(())
}

fn format_rust(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["fmt"];
        cmd.args(args).run()?;
    }

    Ok(())
}
