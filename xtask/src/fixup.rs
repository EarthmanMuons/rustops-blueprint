use anyhow::Result;
use xshell::Shell;

use crate::commands::{actionlint_cmd, cargo_cmd, prettier_cmd, typos_cmd};
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

    let cmd_option = typos_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["--write-changes"];
        cmd.args(args).run()?;
    }

    Ok(())
}

pub fn github_actions(config: &Config) -> Result<()> {
    lint_workflows(config)?;
    Ok(())
}

pub fn markdown(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = prettier_cmd(config, &sh);
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

fn lint_workflows(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = actionlint_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        cmd.run()?;
    }

    Ok(())
}

fn lint_rust(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(_cmd) = cmd_option {
        let args = vec!["fix", "--allow-no-vcs", "--all-targets", "--edition-idioms"];
        cargo_cmd(config, &sh).unwrap().args(args).run()?;

        let args = vec!["clippy", "--fix", "--allow-no-vcs", "--all-targets"];
        cargo_cmd(config, &sh).unwrap().args(args).run()?;

        let args = vec!["clippy", "--all-targets", "--", "-D", "warnings"];
        cargo_cmd(config, &sh).unwrap().args(args).run()?;
    }

    Ok(())
}

fn format_rust(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["+nightly", "fmt"];
        cmd.args(args).run()?;
    }

    Ok(())
}
