# Security Policy

## Reporting a vulnerability

If you find a security issue in this repository — for example a script that
could damage a user's `$HOME`, an installer path traversal, or a committed
secret — **please do not open a public issue**.

Instead, use GitHub's private vulnerability reporting:
<https://github.com/roman-zaglauer/dot-files/security/advisories/new>

Expect an initial response within 7 days.

## Scope

In scope:
- `install.sh`, `uninstall.sh`, and the tracked dotfiles under `home/`.
- GitHub Actions workflows under `.github/workflows/`.

Out of scope:
- Bugs in third-party tools referenced by these dotfiles (bash, git, fzf, gh, …).
- Issues that only reproduce with a user-supplied `~/.dotfiles/*` override.

## Secrets in history

If you discover that a real secret has been committed, please report it
privately so it can be rotated and history rewritten before public disclosure.
