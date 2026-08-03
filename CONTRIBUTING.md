# Contributing

Thanks for stopping by. This repo is primarily for personal use, but PRs that
fix bugs or improve portability are welcome.

## Ground rules

- **No secrets.** No tokens, keys, identity, hostnames, or private paths.
  Anything machine-specific belongs in `~/.gitconfig.local` / `~/.bashrc.local`.
- **Portable bash.** Target `bash >= 4` on Linux, WSL, and macOS. Avoid
  bashisms only available on very new versions.
- **Shellcheck clean.** CI runs [shellcheck](https://www.shellcheck.net/) on
  every `.sh` file — fix warnings before opening a PR.
- **No new top-level dotfiles without a package entry.** Add the file to
  `home/`, then register it in the `PACKAGES` map in `install.sh` and
  `uninstall.sh`, and document it in the README.

## Local check

```bash
shellcheck install.sh uninstall.sh
./install.sh --dry-run all
```

## Commit style

Conventional commits are appreciated but not required. Keep the subject line
under 72 chars and imperative ("add fzf integration", not "added…").
