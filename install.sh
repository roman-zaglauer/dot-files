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
# Every file listed in `home/` is deployed as `$HOME/.<name>` via a symlink.
# Existing regular files/dirs at the destination are backed up to
# `$HOME/.dotfiles-backup/<timestamp>/` unless --no-backup or --force is given.

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
SRC_DIR="$REPO_DIR/home"
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
)
PACKAGE_ORDER=(bash git editor)

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

usage() { sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

list_packages() {
  log "${C_BOLD}Available packages:${C_RESET}"
  for pkg in "${PACKAGE_ORDER[@]}"; do
    printf '  %-8s %s\n' "$pkg" "${PACKAGES[$pkg]}"
  done
}

# --- interactive picker (no external deps) ---------------------------------
pick_interactive() {
  log "${C_BOLD}Select packages to install${C_RESET} (space-separated numbers, 'a' for all, empty to cancel):"
  local i=1
  for pkg in "${PACKAGE_ORDER[@]}"; do
    printf '  [%d] %-8s → %s\n' "$i" "$pkg" "${PACKAGES[$pkg]}"
    i=$((i + 1))
  done
  printf '> '
  local reply; read -r reply
  [ -z "$reply" ] && { warn "Nothing selected."; exit 0; }
  if [ "$reply" = "a" ] || [ "$reply" = "all" ]; then
    SELECTED=("${PACKAGE_ORDER[@]}"); return
  fi
  SELECTED=()
  for n in $reply; do
    [[ "$n" =~ ^[0-9]+$ ]] || { err "Not a number: $n"; exit 1; }
    local idx=$((n - 1))
    [ "$idx" -ge 0 ] && [ "$idx" -lt "${#PACKAGE_ORDER[@]}" ] \
      || { err "Out of range: $n"; exit 1; }
    SELECTED+=("${PACKAGE_ORDER[$idx]}")
  done
}

link_one() {
  local file="$1"                 # e.g. bashrc
  local src="$SRC_DIR/$file"
  local dest="$HOME/.$file"

  [ -e "$src" ] || { err "Missing source: $src"; return 1; }

  if [ -L "$dest" ] && [ "$(readlink -- "$dest")" = "$src" ]; then
    ok "already linked: ~/.$file"
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$FORCE" -eq 1 ]; then
      [ "$DRY_RUN" -eq 1 ] && info "would rm  $dest" || rm -rf -- "$dest"
    elif [ "$NO_BACKUP" -eq 1 ]; then
      warn "skipping existing (no --force / no backup): ~/.$file"
      return 0
    else
      mkdir -p -- "$BACKUP_ROOT"
      if [ "$DRY_RUN" -eq 1 ]; then
        info "would backup $dest → $BACKUP_ROOT/.$file"
      else
        mv -- "$dest" "$BACKUP_ROOT/.$file"
        warn "backed up ~/.$file → $BACKUP_ROOT/.$file"
      fi
    fi
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    info "would link $dest → $src"
  else
    ln -s -- "$src" "$dest"
    ok "linked ~/.$file → ${src#$HOME/}"
  fi
}

install_package() {
  local pkg="$1"
  local files="${PACKAGES[$pkg]:-}"
  [ -n "$files" ] || { err "Unknown package: $pkg"; return 1; }
  log ""
  log "${C_BOLD}Installing package: $pkg${C_RESET}"
  for f in $files; do link_one "$f"; done
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
log "  • Set git identity: mkdir -p ~/.dotfiles && cp docs/gitconfig.local.example ~/.dotfiles/gitconfig && \$EDITOR ~/.dotfiles/gitconfig"
log "  • Machine-local env: create ~/.dotfiles/bashrc for host-specific overrides"
