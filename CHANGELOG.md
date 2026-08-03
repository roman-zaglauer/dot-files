# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] — 2026-08-03

First public release.

### Added
- Packages: `bash` (`bashrc`, `bash_logout`, `profile`, `inputrc`), `git`
  (`gitconfig`, `gitignore_global`), and `editor` (`editorconfig`).
- `install.sh` — interactive picker plus non-interactive modes
  (`all`, named packages, `--list`, `--dry-run`, `--force`, `--no-backup`).
  Symlinks `home/<name>` to `~/.<name>` with timestamped backups under
  `~/.dotfiles-backup/<ts>/`.
- `uninstall.sh` — removes symlinks and restores from the newest backup.
- Local override convention `~/.dotfiles/{bashrc,inputrc,gitconfig}`, with
  the legacy `~/.bashrc.local` and `~/.gitconfig.local` still honoured
  (inspired by [rse/dotfiles](https://github.com/rse/dotfiles)).
- Bash niceties borrowed from rse/dotfiles: `_check_exit_code` prompt hook,
  explicit `LC_CTYPE` and `umask 022`, `tmux-session` helper, and extra
  shopts (`cmdhist`, `lithist`, `checkhash`, `no_empty_cmd_completion`).
- 8-bit-clean readline configuration (`input-meta`, `output-meta`,
  `meta-flag`, `convert-meta off`).
- Corporate CA auto-pickup for Node (`NODE_EXTRA_CA_CERTS`), guarded by file
  existence — no hard-coded corporate paths.
- Public-repo boilerplate: `README`, `LICENSE` (MIT), `CONTRIBUTING`,
  `CODE_OF_CONDUCT`, `SECURITY`, `CHANGELOG`, issue/PR templates,
  `.editorconfig`, `.gitignore`, `docs/gitconfig.local.example`.
- CI: shellcheck + `./install.sh --dry-run all` (`.github/workflows/ci.yml`)
  and gitleaks secret scan on push/PR and weekly
  (`.github/workflows/secret-scan.yml`).
- Dependabot config for GitHub Actions version bumps.

[Unreleased]: https://github.com/roman-zaglauer/dot-files/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/roman-zaglauer/dot-files/releases/tag/v0.1.0
