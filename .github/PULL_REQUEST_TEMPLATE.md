<!-- Thanks for contributing! A short PR is a happy PR. -->

## Summary
<!-- What does this change, and why? Link any related issue. -->

## Type of change
- [ ] Bug fix
- [ ] New dotfile or package
- [ ] Installer / uninstaller change
- [ ] CI / workflow change
- [ ] Documentation only

## Checklist
- [ ] No secrets, keys, tokens, personal identity, or private hostnames added
- [ ] `shellcheck install.sh uninstall.sh` is clean
- [ ] `./install.sh --dry-run all` runs without errors
- [ ] New files under `home/` are registered in the `PACKAGES` map in
      **both** `install.sh` and `uninstall.sh`, and listed in `README.md`
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
