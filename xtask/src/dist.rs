use std::path::{Path, PathBuf};
use std::{env, fs};

use anyhow::Result;
use nanoserde::DeJson;
use xshell::Shell;

use crate::commands::cargo_cmd;
use crate::utils::project_root;
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
    env::set_current_dir(project_root())?;

    if dist_dir().exists() {
        fs::remove_dir_all(dist_dir())?;
    }
    let binaries = project_binaries(config)?;

    for binary in &binaries {
        let dest_dir = dist_dir().join(binary);
        fs::create_dir_all(&dest_dir)?;

        build_binary(config, binary, &dest_dir)?;
        copy_docs(&dest_dir)?;
        // TODO: generate_assets(config, binary, &dest_dir)?;
    }
    Ok(())
}

fn build_binary(config: &Config, binary: &str, dest_dir: &Path) -> Result<()> {
    let sh = Shell::new()?;

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["build", "--release", "--bin", binary];
        cmd.args(args).run()?;
    }

    let binary_filename = if cfg!(target_os = "windows") {
        format!("{binary}.exe")
    } else {
        binary.to_string()
    };
    let src = release_dir().join(&binary_filename);
    let dest = dest_dir.join(&binary_filename);

    fs::copy(&src, &dest)?;
    eprintln!("Copied {} to {}", src.display(), dest.display());

    Ok(())
}

fn copy_docs(dest_dir: &Path) -> Result<()> {
    for file in [
        "CHANGELOG.md",
        "LICENSE",
        "LICENSE-APACHE",
        "LICENSE-MIT",
        "README.md",
    ] {
        let src = PathBuf::from(file);
        if src.exists() {
            let dest = dest_dir.join(file);

            fs::copy(&src, &dest)?;
            eprintln!("Copied {} to {}", src.display(), dest.display());
        }
    }
    Ok(())
}

fn project_binaries(config: &Config) -> Result<Vec<String>> {
    let sh = Shell::new()?;
    let mut binaries = Vec::new();

    let cmd_option = cargo_cmd(config, &sh);
    if let Some(cmd) = cmd_option {
        let args = vec!["metadata", "--no-deps", "--format-version=1"];
        let output = cmd.args(args).output()?;

        let metadata_json = String::from_utf8(output.stdout)?;
        let metadata: Metadata = DeJson::deserialize_json(&metadata_json)?;

        for package in metadata.packages {
            for target in &package.targets {
                if target.name != "xtask" && target.kind.contains(&"bin".to_string()) {
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
