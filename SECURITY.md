# Security Policy

## Reporting a Vulnerability

If you discover a security issue in this repository — for example a script
that could damage a user's `$HOME`, an installer path traversal, or a
committed secret — **please do not open a public issue**.

Instead, use GitHub's private vulnerability reporting:
<https://github.com/roman-zaglauer/dot-files/security/advisories/new>

You can expect an initial response within 7 days.

## Scope

- `install.sh`, `uninstall.sh`, and the tracked dotfiles themselves.
- Any GitHub Actions workflow in `.github/workflows/`.

Out of scope:
- Bugs in third-party tools referenced by these dotfiles (bash, git, fzf, gh).
- Issues that only manifest with an untracked `~/.dotfiles/*` override.

## Secrets in history

If you find that a real secret has been committed, please report it privately
so it can be rotated and history rewritten before public disclosure.
