<!-- Thanks for contributing! Please keep the checklist below. -->

## Summary
<!-- What does this change and why? -->

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
- [ ] If a new file was added under `home/`, it is registered in the
      `PACKAGES` map in **both** `install.sh` and `uninstall.sh` and mentioned
      in `README.md`
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
