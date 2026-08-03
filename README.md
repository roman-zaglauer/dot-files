# dot-files

My personal, portable dotfiles — one repo, one command, any Linux/WSL/macOS box.

Inspired by [rse/dotfiles](https://github.com/rse/dotfiles): small, curated, and
installed via symlinks so edits live in the repo, not scattered across `$HOME`.

## What's inside

| Package  | Files                                                    |
| -------- | -------------------------------------------------------- |
| `bash`   | `.bashrc`, `.bash_logout`, `.profile`, `.inputrc`        |
| `git`    | `.gitconfig`, `.gitignore_global`                        |
| `editor` | `.editorconfig`                                          |

Highlights of the shell config:

- Rich history (dedup, timestamps, shared across sessions, 10k entries)
- Git prompt with branch name, color-safe pager, `LESS -R`
- Curated aliases: git (`gs`, `gc`, `gp`, `gpl`, `glog`, …), npm (`ni`, `nr`, `nrb`, …),
  CAP (`cdw`, `cdb`, `cdx`), navigation (`..`, `...`, `p`, `j <partial>`)
- `fzf` key-bindings & completion when installed
- WSL helpers (`open`, `wslip`, `winpath`, `browser`)
- Optional welcome banner with a BOFH excuse of the week
- Corporate CA auto-pickup for Node (`NODE_EXTRA_CA_CERTS`) if a cert exists
- Machine-local overrides via `~/.bashrc.local` (never tracked)

Git config uses an `[include]` for `~/.gitconfig.local`, so **identity, signing
keys, and credential helpers stay off GitHub**.

## Install

```bash
git clone https://github.com/<your-user>/dot-files.git ~/.dotfiles
cd ~/.dotfiles
./install.sh                 # interactive menu
```

Non-interactive variants:

```bash
./install.sh all             # every package
./install.sh bash git        # only pick what you need
./install.sh --list          # what's available
./install.sh --dry-run all   # preview, change nothing
./install.sh --force all     # overwrite without backup (careful!)
```

The installer creates symlinks like `~/.bashrc → ~/.dotfiles/home/bashrc`.
Existing files are moved to `~/.dotfiles-backup/<timestamp>/` before linking.

## First-run setup

1. Copy the git identity template and fill in your name/email:
   ```bash
   mkdir -p ~/.dotfiles
   cp docs/gitconfig.local.example ~/.dotfiles/gitconfig
   $EDITOR ~/.dotfiles/gitconfig
   ```
2. (Optional) Add host-specific env in `~/.dotfiles/bashrc`.
3. Reload:
   ```bash
   source ~/.bashrc
   ```

### Local override convention

Inspired by [rse/dotfiles](https://github.com/rse/dotfiles), every tracked
dotfile automatically sources an optional untracked counterpart under
`~/.dotfiles/`:

| Tracked file        | Local override               |
| ------------------- | ---------------------------- |
| `~/.bashrc`         | `~/.dotfiles/bashrc`         |
| `~/.inputrc`        | `~/.dotfiles/inputrc`        |
| `~/.gitconfig`      | `~/.dotfiles/gitconfig`      |

`~/.bashrc.local` and `~/.gitconfig.local` are still honoured for backward
compatibility. All of these paths are matched by `.gitignore`.

## Uninstall

```bash
./uninstall.sh all           # remove symlinks, restore newest backup
./uninstall.sh --dry-run all # preview
```

## Layout

```
dot-files/
├── home/                 # tracked dotfiles (no leading dot)
│   ├── bashrc
│   ├── bash_logout
│   ├── profile
│   ├── inputrc
│   ├── gitconfig
│   ├── gitignore_global
│   └── editorconfig
├── docs/
│   └── gitconfig.local.example
├── install.sh            # symlink + backup, interactive or scripted
├── uninstall.sh          # reverse install.sh
├── .github/workflows/    # shellcheck + secret scan
├── LICENSE
└── README.md
```

## Security

- **No secrets, tokens, keys, or personal identity** live in this repo.
- Anything private goes to `~/.gitconfig.local` or `~/.bashrc.local`, both
  explicitly excluded from installation and matched by the tracked
  `.gitignore_global`.
- A CI job (`.github/workflows/secret-scan.yml`) runs [gitleaks](https://github.com/gitleaks/gitleaks)
  on every push to catch accidental leaks.

## License

[MIT](./LICENSE)
