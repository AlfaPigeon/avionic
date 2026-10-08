#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Undo install.sh: remove our symlinks and restore the latest backup.
#
#  Usage: ./uninstall.sh [--dry-run] [-y|--yes]
#
#  Packages, services and the repo itself are left alone; remove them by hand
#  if you want (the summary at the end tells you where things are).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

NAME="hypr-dots"
DOTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/$NAME"
BACKUP_ROOT="$STATE_DIR/backups"
MANIFEST="$DOTS_DIR/scripts/links.conf"
DRY_RUN=0
ASSUME_YES=0

say()  { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }
run()  { if ((DRY_RUN)); then printf '    [dry-run] %s\n' "$*"; else "$@"; fi; }

while (($#)); do
    case "$1" in
        --dry-run) DRY_RUN=1 ;;
        -y|--yes) ASSUME_YES=1 ;;
        -h|--help) sed -n '3,8p' "${BASH_SOURCE[0]}" | sed -E 's/^# {0,2}//'; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

((EUID != 0)) || die "run as your normal user, not root"
[[ -f "$MANIFEST" ]] || die "missing $MANIFEST"

latest=""
if [[ -d "$BACKUP_ROOT" ]]; then
    latest="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)"
fi

say "This will remove $NAME's config links${latest:+ and restore $latest}"
if ((!ASSUME_YES)) && { : </dev/tty; } 2>/dev/null; then
    printf '    Continue? [y/N] ' >/dev/tty
    read -r reply </dev/tty || reply=""
    [[ "${reply,,}" == y* ]] || die "cancelled"
fi

# 1. Remove symlinks that point into this repo (never touch anything else).
say "Removing links"
removed=0
while read -r _src dst _when; do
    [[ -z "${_src:-}" || "$_src" == \#* ]] && continue
    target="$HOME/$dst"
    if [[ -L "$target" && "$(readlink -f "$target")" == "$DOTS_DIR"/* ]]; then
        run rm "$target"
        info "removed ~/$dst"
        removed=$((removed + 1))
    fi
done <"$MANIFEST"
info "$removed link(s) removed"

# 2. Restore the most recent backup, without overwriting anything that exists now.
if [[ -n "$latest" && -f "$latest/manifest" ]]; then
    say "Restoring $(basename "$latest")"
    while read -r rel; do
        [[ -n "$rel" ]] || continue
        if [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]]; then
            warn "$HOME/$rel exists, left the backup copy in place"
            continue
        fi
        run mkdir -p "$(dirname "$HOME/$rel")"
        run mv "$latest/$rel" "$HOME/$rel"
        info "restored ~/$rel"
    done <"$latest/manifest"
    ((DRY_RUN)) || run mv "$latest/manifest" "$latest/manifest.restored"
else
    info "no backup to restore"
fi

say "Done"
info "Still installed: packages, enabled services, and the repo at $DOTS_DIR"
info "Remove the repo with: rm -rf '$DOTS_DIR'   (backups stay in $BACKUP_ROOT)"
