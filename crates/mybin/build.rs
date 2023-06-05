#![deny(clippy::all)]
#![warn(clippy::nursery, clippy::pedantic)]

use std::env;
use std::process::Command;

fn main() {
    let pkg_name = env!("CARGO_PKG_NAME").to_ascii_uppercase();

    let commit_hash = git_command(&["rev-parse", "HEAD"]).map(|hash| {
        println!("cargo:rustc-env={pkg_name}_COMMIT_HASH={hash}");
        hash[..12].to_string()
    });

    let commit_date = git_command(&["show", "-s", "--format=%cs"]).map(|date| {
        println!("cargo:rustc-env={pkg_name}_COMMIT_DATE={date}");
        date
    });

    let is_dirty = Command::new("git")
        .args(["diff", "--quiet", "HEAD", "--"])
        .status()
        .map_or(false, |status| !status.success());

    if let (Some(hash), Some(date)) = (commit_hash, commit_date) {
        let dirty_flag = if is_dirty { ".dirty" } else { "" };
        let version = format!(
            "{} ({}{} {})",
            env!("CARGO_PKG_VERSION"),
            hash,
            dirty_flag,
            date
        );
        println!("cargo:rustc-env={pkg_name}_VERSION={version}");
    }
}

fn git_command(args: &[&str]) -> Option<String> {
    Command::new("git")
        .args(args)
        .output()
        .ok()
        .map(|output| String::from_utf8_lossy(&output.stdout).trim().to_string())
        .filter(|s| !s.is_empty())
}
