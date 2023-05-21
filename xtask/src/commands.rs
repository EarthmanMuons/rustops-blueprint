use anyhow::Result;
use which::which;
use xshell::{cmd, Cmd, Shell};

use crate::Config;

pub fn actionlint_cmd<'a>(config: &Config, sh: &'a Shell) -> Option<Cmd<'a>> {
    create_cmd(
        "actionlint",
        "https://github.com/rhysd/actionlint",
        config,
        sh,
    )
}

pub fn cargo_cmd<'a>(config: &Config, sh: &'a Shell) -> Option<Cmd<'a>> {
    let cargo = std::env::var("CARGO").unwrap_or_else(|_| "cargo".to_string());
    create_cmd(
        cargo.as_str(),
        "https://www.rust-lang.org/learn/get-started",
        config,
        sh,
    )
}

pub fn codespell_cmd<'a>(config: &Config, sh: &'a Shell) -> Option<Cmd<'a>> {
    create_cmd(
        "codespell",
        "https://github.com/codespell-project/codespell",
        config,
        sh,
    )
}

pub fn cue_cmd<'a>(config: &Config, sh: &'a Shell) -> Option<Cmd<'a>> {
    create_cmd("cue", "https://cuelang.org/", config, sh)
}

pub fn prettier_cmd<'a>(config: &Config, sh: &'a Shell) -> Option<Cmd<'a>> {
    create_cmd("prettier", "https://prettier.io", config, sh)
}

fn create_cmd<'a>(
    cmd_name: &str,
    install_url: &str,
    config: &Config,
    sh: &'a Shell,
) -> Option<Cmd<'a>> {
    if check_command(cmd_name, install_url, config).is_err() {
        return None;
    }

    let cmd = cmd!(sh, "{cmd_name}");

    Some(cmd)
}

fn check_command(cmd_name: &str, install_url: &str, config: &Config) -> Result<()> {
    // only ignore missing commands when not running in a CI environment
    let is_local = !is_ci::cached();
    match which(cmd_name) {
        Ok(_) => {
            // the command exists, we're good
            Ok(())
        }
        Err(_) if config.ignore_missing_commands && is_local => {
            println!("Warning: command not found `{cmd_name}`");
            println!("Install: {install_url}");
            Err(anyhow::Error::msg("command is missing, but ignored"))
        }
        Err(_) if is_ci::cached() => {
            println!("Error: command not found `{cmd_name}`");
            println!("Install: {install_url}");
            std::process::exit(1);
        }
        Err(_) => {
            println!("Error: command not found `{cmd_name}`; skip this task with --ignore-missing");
            println!("Install: {install_url}");
            std::process::exit(1);
        }
    }
}
