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
BIN_SRC_DIR="$REPO_DIR/bin"
BIN_DEST_DIR="$HOME/.local/bin"
DRY_RUN=0
NO_RESTORE=0

declare -A PACKAGES=(
  [bash]="bashrc bash_logout profile inputrc"
  [git]="gitconfig gitignore_global"
  [editor]="editorconfig"
  [tmux]="tmux.conf"
)
declare -A BIN_PACKAGES=(
  [tmux]="tmux-restore"
)
PACKAGE_ORDER=(bash git editor tmux)

info() { printf '» %s\n' "$*"; }
ok()   { printf '✓ %s\n' "$*"; }
warn() { printf '! %s\n' "$*"; }

# Render an absolute path under $HOME for display, e.g. /home/me/.bashrc
# becomes ~/.bashrc. The tilde here is deliberately literal (display only).
pretty_path() { printf '~%s' "${1#"$HOME"}"; }

newest_backup_for() {
  local backup_name="$1"
  find "$HOME/.dotfiles-backup" -mindepth 2 -maxdepth 2 -name "$backup_name" \
    -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr | head -n1 | cut -d' ' -f2-
}

unlink_path() {
  local src="$1" dest="$2" backup_name="$3"
  local label; label="$(pretty_path "$dest")"
  if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then info "would rm  $dest"; else rm -- "$dest"; fi
    ok "removed $label"
    if [ "$NO_RESTORE" -eq 0 ]; then
      local backup; backup="$(newest_backup_for "$backup_name" || true)"
      if [ -n "$backup" ] && [ -e "$backup" ]; then
        if [ "$DRY_RUN" -eq 1 ]; then
          info "would restore $backup → $dest"
        else
          cp -a -- "$backup" "$dest"
          ok "restored $label from $backup"
        fi
      fi
    fi
  else
    warn "not a link we own: $label (skipped)"
  fi
}

unlink_one() {
  local file="$1"
  unlink_path "$SRC_DIR/$file" "$HOME/.$file" ".$file"
}

unlink_bin() {
  local file="$1"
  unlink_path "$BIN_SRC_DIR/$file" "$BIN_DEST_DIR/$file" "$file"
}

SELECTED=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)   DRY_RUN=1 ;;
    --no-restore)   NO_RESTORE=1 ;;
    all)            SELECTED=("${PACKAGE_ORDER[@]}") ;;
    -h|--help)      awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"; exit 0 ;;
    *)              SELECTED+=("$1") ;;
  esac
  shift
done
[ "${#SELECTED[@]}" -eq 0 ] && SELECTED=("${PACKAGE_ORDER[@]}")

for pkg in "${SELECTED[@]}"; do
  for f in ${PACKAGES[$pkg]:-};     do unlink_one "$f"; done
  for b in ${BIN_PACKAGES[$pkg]:-}; do unlink_bin "$b"; done
done
