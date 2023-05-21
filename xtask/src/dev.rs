use anyhow::Result;
use xshell::Shell;

use crate::commands::cargo_cmd;
use crate::utils::{project_root, verbose_cd};
use crate::Config;

pub fn cargo_watch(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec![
            "watch",
            "--why",
            "-x",
            "clippy --locked --all-targets --all-features",
        ];
        cmd.args(args).run()?;
    }

    Ok(())
}
