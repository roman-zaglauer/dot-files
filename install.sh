#!/usr/bin/env bash
# install.sh — symlink selected dotfiles from this repo into $HOME.
#
# Usage:
#   ./install.sh                  # interactive picker
#   ./install.sh all              # install every package
#   ./install.sh bash git         # install specific packages
#   ./install.sh --list           # list available packages
#   ./install.sh --dry-run all    # show what would happen
#   ./install.sh --force all      # overwrite without backup
#   ./install.sh --no-backup all  # skip backup step
#
# Every file listed in `home/` is deployed as `$HOME/.<name>` via a symlink,
# and every file listed in `bin/` as `$HOME/.local/bin/<name>`.
# Existing regular files/dirs at the destination are backed up to
# `$HOME/.dotfiles-backup/<timestamp>/` unless --no-backup or --force is given.

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SRC_DIR="$REPO_DIR/home"
BIN_SRC_DIR="$REPO_DIR/bin"
BIN_DEST_DIR="$HOME/.local/bin"
BACKUP_ROOT="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0
NO_BACKUP=0

# --- packages: name -> space-separated list of files in home/ ---------------
# Files are stored WITHOUT the leading dot; they are symlinked as ~/.<name>.
declare -A PACKAGES=(
  [bash]="bashrc bash_logout profile inputrc"
  [git]="gitconfig gitignore_global"
  [editor]="editorconfig"
  [tmux]="tmux.conf"
)
# Optional per-package executables in bin/, symlinked into ~/.local/bin
# (no leading dot, executable bit preserved via the symlink target).
declare -A BIN_PACKAGES=(
  [tmux]="tmux-restore"
)
PACKAGE_ORDER=(bash git editor tmux)

# --- colours ----------------------------------------------------------------
if [ -t 1 ]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
  C_RED=$'\033[31m'; C_CYAN=$'\033[36m'
else
  C_RESET=""; C_BOLD=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_CYAN=""
fi

log()   { printf '%s\n' "$*"; }
info()  { printf '%s%s%s %s\n' "$C_CYAN"  "»" "$C_RESET" "$*"; }
ok()    { printf '%s%s%s %s\n' "$C_GREEN" "✓" "$C_RESET" "$*"; }
warn()  { printf '%s%s%s %s\n' "$C_YELLOW" "!" "$C_RESET" "$*"; }
err()   { printf '%s%s%s %s\n' "$C_RED"    "✗" "$C_RESET" "$*" >&2; }

# Render an absolute path under $HOME for display, e.g. /home/me/.bashrc
# becomes ~/.bashrc. The tilde here is deliberately literal (display only).
pretty_path() { printf '~%s' "${1#"$HOME"}"; }

usage() { awk 'NR>1 && /^#/ { sub(/^# ?/, ""); print; next } NR>1 { exit }' "$0"; exit "${1:-0}"; }

# Human-readable contents of a package: dotfiles as ~/.<name>, plus any
# executables the package installs into ~/.local/bin.
package_contents() {
  local pkg="$1" out=""
  local files="${PACKAGES[$pkg]:-}"
  local bins="${BIN_PACKAGES[$pkg]:-}"
  for f in $files; do out+=" .$f"; done
  for b in $bins;  do out+=" bin/$b"; done
  printf '%s' "${out# }"
}

list_packages() {
  log "${C_BOLD}Available packages:${C_RESET}"
  for pkg in "${PACKAGE_ORDER[@]}"; do
    printf '  %-8s %s\n' "$pkg" "$(package_contents "$pkg")"
  done
}

# --- interactive picker (no external deps) ---------------------------------
pick_interactive() {
  log "${C_BOLD}dot-files installer${C_RESET}"
  local i=1
  for pkg in "${PACKAGE_ORDER[@]}"; do
    printf '  [%d] %-8s (%s)\n' "$i" "$pkg" "$(package_contents "$pkg")"
    i=$((i + 1))
  done
  printf '  [a] all   [q] quit\n'
  printf '» select: '
  local reply
  if ! read -r reply; then warn "cancelled"; exit 0; fi
  case "${reply// /}" in
    ''|q|Q|quit) warn "cancelled"; exit 0 ;;
    a|A|all)     SELECTED=("${PACKAGE_ORDER[@]}"); return ;;
  esac
  SELECTED=()
  for n in $reply; do
    [[ "$n" =~ ^[0-9]+$ ]] || { err "Not a number: $n"; exit 1; }
    local idx=$((n - 1))
    [ "$idx" -ge 0 ] && [ "$idx" -lt "${#PACKAGE_ORDER[@]}" ] \
      || { err "Out of range: $n"; exit 1; }
    SELECTED+=("${PACKAGE_ORDER[$idx]}")
  done
}

link_path() {
  local src="$1"                  # absolute path inside the repo
  local dest="$2"                 # absolute destination path
  local backup_name="$3"          # file name used inside the backup dir
  local label; label="$(pretty_path "$dest")"

  [ -e "$src" ] || { err "Missing source: $src"; return 1; }

  if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
    ok "already linked: $label"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$FORCE" -eq 1 ]; then
      if [ "$DRY_RUN" -eq 1 ]; then info "would rm  $dest"; else rm -rf -- "$dest"; fi
    elif [ "$NO_BACKUP" -eq 1 ]; then
      warn "skipping existing (no --force / no backup): $label"
      return 0
    else
      if [ "$DRY_RUN" -eq 1 ]; then
        info "would backup $dest → $BACKUP_ROOT/$backup_name"
      else
        mkdir -p -- "$BACKUP_ROOT"
        mv -- "$dest" "$BACKUP_ROOT/$backup_name"
        warn "backed up $label → $BACKUP_ROOT/$backup_name"
      fi
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "would link $dest → $src"
  else
    mkdir -p -- "$(dirname -- "$dest")"
    ln -s -- "$src" "$dest"
    ok "linked $label → ${src#"$HOME"/}"
  fi
}

link_one() {
  local file="$1"                 # e.g. bashrc
  link_path "$SRC_DIR/$file" "$HOME/.$file" ".$file"
}

link_bin() {
  local file="$1"                 # e.g. tmux-restore
  link_path "$BIN_SRC_DIR/$file" "$BIN_DEST_DIR/$file" "$file"
}

install_package() {
  local pkg="$1"
  local files="${PACKAGES[$pkg]:-}"
  local bins="${BIN_PACKAGES[$pkg]:-}"
  [ -n "$files" ] || [ -n "$bins" ] || { err "Unknown package: $pkg"; return 1; }
  log ""
  log "${C_BOLD}Installing package: $pkg${C_RESET}"
  for f in $files; do link_one "$f"; done
  for b in $bins;  do link_bin "$b"; done
}

# --- argument parsing -------------------------------------------------------
SELECTED=()
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)      usage 0 ;;
    -l|--list)      list_packages; exit 0 ;;
    -n|--dry-run)   DRY_RUN=1 ;;
    -f|--force)     FORCE=1 ;;
    --no-backup)    NO_BACKUP=1 ;;
    all)            SELECTED=("${PACKAGE_ORDER[@]}") ;;
    -*)             err "Unknown flag: $1"; usage 1 ;;
    *)              SELECTED+=("$1") ;;
  esac
  shift
done

[ "${#SELECTED[@]}" -eq 0 ] && pick_interactive

log "${C_BOLD}Dotfiles installer${C_RESET}"
log "  repo:     $REPO_DIR"
log "  packages: ${SELECTED[*]}"
[ "$DRY_RUN" -eq 1 ] && warn "dry-run: no changes will be made"

for pkg in "${SELECTED[@]}"; do install_package "$pkg"; done

log ""
ok "Done."
log ""
log "Next steps:"
log "  • Reload bash:      source ~/.bashrc"
log "  • Set git identity: mkdir -p ~/.dotfiles && cp $REPO_DIR/docs/gitconfig.local.example ~/.dotfiles/gitconfig && \$EDITOR ~/.dotfiles/gitconfig"
log "  • Machine-local env: create ~/.dotfiles/bashrc for host-specific overrides"
log "  • tmux plugins:     git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && tmux source-file ~/.tmux.conf"
log "  • tmux auto-restore after reboot: loginctl enable-linger \$USER (see README)"
