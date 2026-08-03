# Contributing

Thanks for stopping by! This repo is primarily for my own daily use, but
bug fixes, portability improvements, and shellcheck cleanups are very
welcome. For anything larger, please open an issue first so we can agree on
scope before you spend time on a PR.

## Ground rules

- **No secrets.** No tokens, keys, identity, hostnames, or private paths in
  tracked files. Machine-specific stuff belongs in `~/.dotfiles/*` (or the
  legacy `~/.bashrc.local` / `~/.gitconfig.local`).
- **Portable bash.** Target `bash >= 4` on Linux, WSL, and macOS. Avoid
  features that only ship with very new versions, and guard optional tools
  (`command -v fzf >/dev/null && …`).
- **Shellcheck clean.** CI runs [shellcheck](https://www.shellcheck.net/) on
  every `.sh` file — please fix warnings before opening a PR.
- **New dotfile → new package entry.** If you add a file under `home/`,
  register it in the `PACKAGES` map in **both** `install.sh` and
  `uninstall.sh`, and mention it in the `README.md` table.

## Local verification loop

Run these before pushing — they're exactly what CI runs:

```bash
shellcheck install.sh uninstall.sh
./install.sh --list
./install.sh --dry-run all
```

If you're on a machine that already has the dotfiles installed, `--dry-run`
is safe: it prints what would change without touching anything.

## Commit style

Conventional Commits are appreciated but not required. Keep the subject
line under 72 characters and imperative — "add fzf integration", not
"added fzf integration".

## PR checklist

- [ ] `shellcheck install.sh uninstall.sh` passes
- [ ] `./install.sh --dry-run all` runs cleanly
- [ ] No secrets, identity, or private paths added
- [ ] `CHANGELOG.md` updated under `[Unreleased]`

Thanks again — every small fix helps keep this repo pleasant to live in.
