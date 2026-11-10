# dot-files

[![CI](https://github.com/roman-zaglauer/dot-files/actions/workflows/ci.yml/badge.svg)](https://github.com/roman-zaglauer/dot-files/actions/workflows/ci.yml)
[![Secret scan](https://github.com/roman-zaglauer/dot-files/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/roman-zaglauer/dot-files/actions/workflows/secret-scan.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

A small, portable set of dotfiles for **bash**, **git**, **editorconfig**, and
**tmux** — one repo, one command, any Linux/WSL/macOS box. Configs live in this
repo and land in `$HOME` as symlinks, so an edit here is an edit everywhere.

Inspired by [rse/dotfiles](https://github.com/rse/dotfiles). Curated for my
own daily use; shared publicly in case any of it is useful to you.

## Quickstart

```bash
git clone https://github.com/roman-zaglauer/dot-files.git ~/.local/share/dot-files
cd ~/.local/share/dot-files
./install.sh                 # interactive picker
```

That's it. Existing files are moved to `~/.dotfiles-backup/<timestamp>/`
before any symlink is created, so nothing is silently overwritten.

> ⚠️ Do **not** clone into `~/.dotfiles/` — that path is reserved for
> untracked, machine-local overrides (see [Local overrides](#local-overrides)).

Sample interactive session:

```
» dot-files installer
  [1] bash    (.bashrc .bash_logout .profile .inputrc)
  [2] git     (.gitconfig .gitignore_global)
  [3] editor  (.editorconfig)
  [4] tmux    (.tmux.conf bin/tmux-restore)
  [a] all   [q] quit
» select: 1 2
✓ linked ~/.bashrc → ~/.local/share/dot-files/home/bashrc
✓ backed up existing ~/.gitconfig → ~/.dotfiles-backup/20260803-103300/
```

## What's inside

| Package  | Files                                             |
| -------- | ------------------------------------------------- |
| `bash`   | `.bashrc`, `.bash_logout`, `.profile`, `.inputrc` |
| `git`    | `.gitconfig`, `.gitignore_global`                 |
| `editor` | `.editorconfig`                                   |
| `tmux`   | `.tmux.conf`, `~/.local/bin/tmux-restore`         |

Shell highlights:

- Rich history — dedup, timestamps, shared across sessions, 10k entries
- Git-aware prompt, colour-safe pager, `LESS -R`
- Curated aliases: git (`gs`, `gc`, `gp`, `gpl`, `glog`, …), npm (`ni`, `nr`,
  `nrb`, …), SAP CAP (`cdw`, `cdb`, `cdx`), navigation (`..`, `...`, `p`,
  `j <partial>`)
- `fzf` key-bindings and completion when installed
- WSL helpers (`open`, `wslip`, `winpath`, `browser`)
- Non-zero exit codes printed in red via a `_check_exit_code` prompt hook
- Optional welcome banner with a BOFH excuse of the week
- Corporate CA auto-pickup for Node (`NODE_EXTRA_CA_CERTS`) if a cert exists
- 8-bit-clean readline (`input-meta`, `output-meta`, `convert-meta off`)
- `tmux-session <name>` helper for reusable named sessions

tmux highlights: `C-a` prefix, vi keys, splits that keep the working
directory, clipboard autodetection (WSL `clip.exe`, `xclip`, `wl-copy`, OSC 52),
and a plugin-free Catppuccin Mocha theme.

Git config `[include]`s `~/.gitconfig.local`, so **identity, signing keys,
and credential helpers stay off GitHub**.

## tmux

`.tmux.conf` targets tmux ≥ 3.2 (`display-popup`) and uses
[TPM](https://github.com/tmux-plugins/tpm) for three plugins. Highlights:

- `C-a` prefix, `|`/`-` splits that keep the current directory, vim-style pane
  navigation, 1-based window/pane indexing with `renumber-windows`
- vi copy-mode, OSC 52 clipboard (works over SSH) with a local backend picked
  at load time: `wl-copy` → `xclip` → `clip.exe`
- Catppuccin Mocha status bar, no Nerd Font or plugin required
- `extended-keys` + `terminal-features` so `Ctrl-Shift-<key>` reaches Neovim
- Session persistence via `tmux-resurrect` (`prefix + M-s` / `M-r`) and
  `tmux-continuum` (auto-save every 5 min, auto-restore on server start)

Bootstrap TPM once, then install the plugins with `prefix + I`:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux source-file ~/.tmux.conf
```

### Surviving a reboot

tmux keeps all session state in server memory, so a reboot — or a
`wsl --shutdown` — destroys it. Restoring automatically needs **three** things,
and the last one is easy to miss:

1. `@continuum-restore 'on'` — restore saved sessions when the server starts.
2. `@continuum-boot 'on'` — actually *start* a server at boot. Continuum
   installs `~/.config/systemd/user/tmux.service` for this. Without it nothing
   restores until the first manual `tmux` call, by which point the guard in
   step 3 usually blocks it anyway.

Both are set in `tmux.conf`. On a systemd machine also enable lingering, so
the user manager (and the unit) starts without an interactive login:

```bash
loginctl enable-linger "$USER"
systemctl --user enable tmux.service    # enable only — see the warning below
```

> **Do not run `systemctl --user start` (or `enable --now`) while a tmux
> server is already running.** `tmux start-server` returns immediately when a
> server exists, so the `Type=forking` unit never finds a process to track,
> drops straight to `inactive`, and runs its `ExecStop` — whose second line is
> `tmux kill-server`. Starting the unit by hand therefore destroys the running
> server and every session in it. Let it start on its own at boot, when no
> server exists yet.

On WSL this additionally requires `systemd=true` under `[boot]` in
`/etc/wsl.conf`.

3. `@continuum-systemd-start-cmd 'start-server'` — **the one that is easy to
   get wrong.** The unit's default `ExecStart` is `tmux new-session -d`, which
   gives the boot server a throwaway session `0`. `tmux-resurrect` sees a
   server holding exactly one pane, decides it is "restoring from scratch",
   and kills session `0` when it finishes — *including when it restored
   nothing at all*. The server is then empty, `exit-empty` (on by default)
   makes it quit, systemd runs `ExecStop` against a dead server, and
   `save.sh` happily writes a **0-byte save** and repoints `last` at it. The
   previous good save is gone and every later boot has nothing to restore.

   `start-server` creates no session, so none of that is triggered. It is the
   documented alternative in [continuum's systemd docs][continuum-systemd].

Because `start-server` starts a server with no sessions, `tmux.conf` also sets
`exit-empty off` — tmux(1) calls this out explicitly:

> Note that as by default the tmux server will exit with no sessions, this is
> only useful if a session is created in `~/.tmux.conf`, `exit-empty` is
> turned off, or another command is run as part of the same command sequence.

With the server kept alive, the unit's `ExecStop` runs `save.sh` against a
*live* server, so the shutdown save is a real one.

[continuum-systemd]: https://github.com/tmux-plugins/tmux-continuum/blob/master/docs/systemd_details.md

Two upstream behaviours worth knowing:

- **Auto-restore is skipped silently when another tmux server is running.**
  `tmux-continuum` guards restore with `another_tmux_server_running_on_startup`
  to avoid clobbering state across environments. Starting a second server by
  hand therefore restores nothing, with no error.
- **`restore.sh` run from a plain shell restores into an invisible server.**
  It derives the socket from `$TMUX`, which is unset outside tmux, and runs
  `tmux -S '' new-session` — an orphaned server `tmux ls` never lists. Use
  `tmux-restore` (shipped in `bin/`) instead; inside tmux it is a passthrough.

```bash
tmux-restore                 # restore into the running server
tmux-restore -L work         # ...on a named socket
```

`@continuum-restore-max-delay` is raised to 30s because the 10s default can be
missed on a cold boot, which also silently skips the restore.

Continuum writes `tmux.service` **only when the file does not already exist**,
so changing `@continuum-systemd-start-cmd` on a machine that already has the
unit needs it regenerated:

```bash
rm ~/.config/systemd/user/tmux.service
tmux source-file ~/.tmux.conf      # continuum rewrites and re-enables it
systemctl --user daemon-reload
grep ExecStart ~/.config/systemd/user/tmux.service   # => tmux start-server
```

## Installer

```bash
./install.sh                 # interactive menu
./install.sh all             # every package, non-interactive
./install.sh bash git        # pick what you want
./install.sh --list          # show available packages
./install.sh --dry-run all   # preview, change nothing
./install.sh --force all     # overwrite without backup (careful!)
./install.sh --no-backup all # skip the backup step
```

The installer creates symlinks like
`~/.bashrc → <repo>/home/bashrc`, and for package executables
`~/.local/bin/tmux-restore → <repo>/bin/tmux-restore`. Existing regular files
or directories at the destination are moved to
`~/.dotfiles-backup/<timestamp>/` first, unless `--force` or `--no-backup` is
passed.

To reverse the process:

```bash
./uninstall.sh all           # remove symlinks, restore newest backup
./uninstall.sh --dry-run all # preview
```

## Local overrides

Every tracked config sources an optional, **untracked** override from
`~/.dotfiles/`. This is where anything private, host-specific, or
work-specific belongs — identity, credential helpers, corporate CA paths,
per-machine aliases.

| Tracked config | Sources (if present)                              |
| -------------- | ------------------------------------------------- |
| `~/.bashrc`    | `~/.dotfiles/bashrc`, then `~/.bashrc.local`      |
| `~/.inputrc`   | `~/.dotfiles/inputrc`                             |
| `~/.gitconfig` | `~/.dotfiles/gitconfig`, then `~/.gitconfig.local`|
| `~/.tmux.conf` | `~/.dotfiles/tmux.conf`                           |

The `*.local` variants are kept for backward compatibility. All of these
paths are ignored by `.gitignore` and `.gitignore_global`.

### First-run: set your git identity

```bash
mkdir -p ~/.dotfiles
cp docs/gitconfig.local.example ~/.dotfiles/gitconfig
$EDITOR ~/.dotfiles/gitconfig   # fill in name, email, signing key, …
```

Optionally drop host-specific bash bits into `~/.dotfiles/bashrc`, then
`source ~/.bashrc` (or open a new shell).

## Layout

```
dot-files/
├── home/                        # tracked dotfiles (stored without leading dot)
│   ├── bashrc  bash_logout  profile  inputrc
│   ├── gitconfig  gitignore_global
│   ├── editorconfig
│   └── tmux.conf
├── bin/                         # executables → ~/.local/bin/
│   └── tmux-restore
├── docs/gitconfig.local.example
├── install.sh                   # symlink + backup, interactive or scripted
├── uninstall.sh                 # reverses install.sh
├── .github/workflows/           # shellcheck + install dry-run, gitleaks scan
└── README.md · LICENSE · CHANGELOG.md · SECURITY.md · …
```

## Security & privacy

- **No secrets, tokens, keys, or personal identity** live in this repo.
- Anything private goes to `~/.dotfiles/*` (or the legacy `*.local` files),
  which are matched by both `.gitignore` and the tracked `.gitignore_global`.
- CI runs [gitleaks](https://github.com/gitleaks/gitleaks) on every push and
  weekly to catch accidental leaks.
- Found something concerning? See [SECURITY.md](./SECURITY.md).

## Contributing

Small PRs that fix bugs, improve portability, or tighten shellcheck output
are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

[MIT](./LICENSE) · see also [CHANGELOG.md](./CHANGELOG.md) ·
[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md) ·
[SECURITY.md](./SECURITY.md)
