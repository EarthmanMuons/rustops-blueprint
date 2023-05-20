use std::env;
use std::fs;
use std::path::PathBuf;

use anyhow::Result;
use nanoserde::DeJson;
use xshell::Shell;

use crate::commands::cargo_cmd;
use crate::utils::{project_root, verbose_cd};
use crate::Config;

#[derive(Debug, DeJson)]
struct Metadata {
    packages: Vec<Package>,
}

#[derive(Debug, DeJson)]
struct Package {
    #[allow(dead_code)]
    name: String,
    targets: Vec<Target>,
}

#[derive(Debug, DeJson)]
struct Target {
    kind: Vec<String>,
    name: String,
}

pub fn dist(config: &Config) -> Result<()> {
    let _ = fs::remove_dir_all(dist_dir());
    fs::create_dir_all(dist_dir())?;

    dist_binary(config)?;
    // TODO: dist_manpage()?;

    Ok(())
}

fn dist_binary(config: &Config) -> Result<()> {
    let sh = Shell::new()?;
    verbose_cd(&sh, project_root());

    let cmd_option = cargo_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["build", "--release", "--bins"];
        cmd.args(args).run()?;
    }

    let binaries = project_binaries(config)?;
    for binary in &binaries {
        if binary == "xtask" {
            eprintln!("Ignoring xtask binary");
            continue;
        }

        let binary_filename = if cfg!(target_os = "windows") {
            format!("{}.exe", binary)
        } else {
            binary.to_string()
        };
        let src = release_dir().join(&binary_filename);
        let dest = dist_dir().join(&binary_filename);

        eprintln!("Copying {} to {}", src.display(), dest.display());
        fs::copy(&src, &dest)?;
    }

    Ok(())
}

fn project_binaries(config: &Config) -> Result<Vec<String>> {
    let sh = Shell::new()?;
    let mut binaries = Vec::new();

    let cmd_option = cargo_cmd(config, &sh)?;
    if let Some(cmd) = cmd_option {
        let args = vec!["metadata", "--no-deps", "--format-version=1"];
        let output = cmd.args(args).output()?;

        let metadata_json = String::from_utf8(output.stdout)?;
        let metadata: Metadata = DeJson::deserialize_json(&metadata_json)?;

        for package in metadata.packages {
            for target in &package.targets {
                if target.kind.contains(&"bin".to_string()) {
                    eprintln!("{:?}", package);
                    binaries.push(target.name.clone());
                }
            }
        }
    }

    Ok(binaries)
}

fn dist_dir() -> PathBuf {
    target_dir().join("dist")
}

fn release_dir() -> PathBuf {
    target_dir().join("release")
}

fn target_dir() -> PathBuf {
    let relative_path = env::var("CARGO_TARGET_DIR").unwrap_or_else(|_| "target".to_string());
    PathBuf::from(relative_path)
}
