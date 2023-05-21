use anyhow::Result;
use xshell::Shell;

use crate::commands::cargo_cmd;
use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn html_report(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec![
            "llvm-cov",
            "nextest",
            "--ignore-filename-regex",
            "xtask",
            "--open",
        ];
        cmd.args(args).run()?;
    }

    Ok(())
}

pub fn report_summary(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["llvm-cov", "nextest", "--ignore-filename-regex", "xtask"];
        cmd.args(args).run()?;
    }

    Ok(())
}
