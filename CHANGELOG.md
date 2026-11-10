# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `bin/` directory and matching `BIN_PACKAGES` table — package executables are
  symlinked into `~/.local/bin/<name>`, with the same backup/restore handling
  as `home/` dotfiles.
- `bin/tmux-restore` — safe wrapper around `tmux-resurrect`'s `restore.sh`.
  Run from a plain shell, the upstream script derives its socket from an unset
  `$TMUX` and restores into `tmux -S ''`: a separate, orphaned server that
  `tmux ls` never shows. The wrapper pins `$TMUX` to a real server first.
- `tmux.conf` sources an optional `~/.dotfiles/tmux.conf`, matching the local
  override convention already used by `bashrc`, `inputrc`, and `gitconfig`.
- `tmux.conf`: session persistence via `tmux-resurrect` and `tmux-continuum`.

### Changed
- `tmux.conf` sets `@continuum-boot 'on'` so a tmux server is started at boot
  by a systemd user unit — without it, continuum's restore-on-server-start
  never fires after a reboot and sessions stay lost until the first manual
  `tmux` call.
- README no longer suggests `systemctl --user enable --now tmux.service`.
  `--now` starts the unit while a tmux server is already running; because
  `tmux start-server` exits immediately in that case, the `Type=forking` unit
  finds nothing to track, goes `inactive`, and runs its `ExecStop` —
  `tmux kill-server` — destroying the running server and every session in it.
- `tmux.conf` raises `@continuum-restore-max-delay` to `30` (default `10`);
  the plugin must load within that window of server start or auto-restore is
  silently skipped, which a cold WSL boot can miss.
- `install.sh` / `uninstall.sh`: link and unlink logic factored into shared
  `link_path` / `unlink_path` helpers so dotfiles and executables share one
  code path.

### Fixed
- `tmux.conf` sets `@continuum-systemd-start-cmd 'start-server'` and
  `exit-empty off`, so tmux sessions actually survive a reboot. The unit's
  default `ExecStart` (`tmux new-session -d`) gives the boot server a
  throwaway session `0`; `tmux-resurrect` treats a one-pane server as
  "restoring from scratch" and kills session `0` on completion — even when it
  restored nothing. The empty server then exits, systemd runs `ExecStop`
  against a dead server, and `save.sh` overwrites `last` with a 0-byte save,
  so every subsequent boot had nothing left to restore. `start-server` creates
  no session (the documented alternative in continuum's systemd docs), and
  `exit-empty off` keeps that session-less server alive, as tmux(1) requires.
- `--help` in `install.sh` and `uninstall.sh` printed past the comment header
  into the script body (hard-coded `sed` line ranges). Both now stop at the
  first non-comment line.

## [0.2.0] — 2026-11-06

### Added
- `tmux` package (`tmux.conf`): `C-a` prefix, vi keys, cwd-preserving splits,
  clipboard backend autodetection (clip.exe / xclip / wl-copy, OSC 52), and a
  plugin-free Catppuccin Mocha theme.

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

[Unreleased]: https://github.com/roman-zaglauer/dot-files/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/roman-zaglauer/dot-files/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/roman-zaglauer/dot-files/releases/tag/v0.1.0
