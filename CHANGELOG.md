# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial public release of the dotfiles repository.
- Packages: `bash` (bashrc, bash_logout, profile, inputrc), `git`
  (gitconfig, gitignore_global), `editor` (editorconfig).
- `install.sh` — interactive picker, `--list`, `--dry-run`, `--force`,
  `--no-backup`; symlink deployment with timestamped backups under
  `~/.dotfiles-backup/`.
- `uninstall.sh` — removes links and restores the newest backup.
- Local override convention `~/.dotfiles/{bashrc,inputrc,gitconfig}` inspired
  by [rse/dotfiles](https://github.com/rse/dotfiles).
- Bash niceties borrowed from rse/dotfiles: `_check_exit_code` prompt hook,
  explicit `LC_CTYPE` and `umask 022`, `tmux-session` helper, and additional
  shopts (`cmdhist`, `lithist`, `checkhash`, `no_empty_cmd_completion`).
- 8-bit-clean readline configuration (`input-meta`, `output-meta`, `meta-flag`,
  `convert-meta off`).
- Corporate CA auto-pickup in bash for Node (`NODE_EXTRA_CA_CERTS`) guarded by
  file existence — no hard-coded corp paths.
- Public-repo boilerplate: `README`, `LICENSE` (MIT), `CONTRIBUTING`,
  `CODE_OF_CONDUCT`, `SECURITY`, `CHANGELOG`, issue/PR templates,
  `.editorconfig`, `.gitignore`.
- CI: shellcheck + install dry-run (`.github/workflows/ci.yml`) and gitleaks
  secret scan (`.github/workflows/secret-scan.yml`).
- Dependabot config for GitHub Actions version bumps.

[Unreleased]: https://github.com/roman-zaglauer/dot-files/commits/main
