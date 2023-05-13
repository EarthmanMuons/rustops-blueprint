use std::path::{Path, PathBuf};

use xshell::Shell;

pub(crate) fn project_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .expect("Failed to find project root")
        .to_path_buf()
}

pub(crate) fn verbose_cd<P: AsRef<Path>>(sh: &Shell, dir: P) {
    sh.change_dir(dir);
    eprintln!(
        "\n$ cd {}{}",
        sh.current_dir().display(),
        std::path::MAIN_SEPARATOR
    );
}
