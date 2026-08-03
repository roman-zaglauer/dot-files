# dot-files

[![CI](https://github.com/roman-zaglauer/dot-files/actions/workflows/ci.yml/badge.svg)](https://github.com/roman-zaglauer/dot-files/actions/workflows/ci.yml)
[![Secret scan](https://github.com/roman-zaglauer/dot-files/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/roman-zaglauer/dot-files/actions/workflows/secret-scan.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

A small, portable set of dotfiles for **bash**, **git**, and **editorconfig** —
one repo, one command, any Linux/WSL/macOS box. Configs live in this repo and
land in `$HOME` as symlinks, so an edit here is an edit everywhere.

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

Git config `[include]`s `~/.gitconfig.local`, so **identity, signing keys,
and credential helpers stay off GitHub**.

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
`~/.bashrc → <repo>/home/bashrc`. Existing regular files or directories at
the destination are moved to `~/.dotfiles-backup/<timestamp>/` first, unless
`--force` or `--no-backup` is passed.

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
│   └── editorconfig
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
