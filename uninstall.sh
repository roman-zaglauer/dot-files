#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by install.sh and (optionally) restore
# the newest backup found under ~/.dotfiles-backup/.
#
# Usage:
#   ./uninstall.sh                  # interactive, all packages, auto-restore
#   ./uninstall.sh bash git         # remove specific packages
#   ./uninstall.sh --dry-run all
#   ./uninstall.sh --no-restore all # remove links, do NOT restore backups

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SRC_DIR="$REPO_DIR/home"
DRY_RUN=0
NO_RESTORE=0

declare -A PACKAGES=(
  [bash]="bashrc bash_logout profile inputrc"
  [git]="gitconfig gitignore_global"
  [editor]="editorconfig"
)
PACKAGE_ORDER=(bash git editor)

info() { printf '» %s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }
warn() { printf '! %s\n' "$*"; }

newest_backup_for() {
  local file="$1"
  find "$HOME/.dotfiles-backup" -mindepth 2 -maxdepth 2 -name ".$file" \
    -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr | head -n1 | cut -d' ' -f2-
}

unlink_one() {
  local file="$1"
  local dest="$HOME/.$file"
  local src="$SRC_DIR/$file"
  if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then info "would rm  $dest"; else rm -- "$dest"; fi
    ok "removed ~/.$file"
    if [ "$NO_RESTORE" -eq 0 ]; then
      local backup; backup="$(newest_backup_for "$file" || true)"
      if [ -n "$backup" ] && [ -e "$backup" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
          info "would restore $backup → $dest"
        else
          cp -a -- "$backup" "$dest"
          ok "restored ~/.$file from $backup"
        fi
      fi
    fi
  else
    warn "not a link we own: ~/.$file (skipped)"
  fi
}

SELECTED=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)   DRY_RUN=1 ;;
    --no-restore)   NO_RESTORE=1 ;;
    all)            SELECTED=("${PACKAGE_ORDER[@]}") ;;
    -h|--help)      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)              SELECTED+=("$1") ;;
  esac
  shift
done
[ "${#SELECTED[@]}" -eq 0 ] && SELECTED=("${PACKAGE_ORDER[@]}")

for pkg in "${SELECTED[@]}"; do
  for f in ${PACKAGES[$pkg]:-}; do unlink_one "$f"; done
done
