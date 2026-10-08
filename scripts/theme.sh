#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Switch the desktop theme.
#
#  Usage: theme.sh <name>      render themes/<name> everywhere and reload
#         theme.sh list        list the themes (the current one is marked)
#         theme.sh current     print the current theme
#
#  The choice is saved in ~/.local/state/avionic/theme; scripts/apply-theme.sh
#  renders it from then on. The default is magma.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
THEMES_DIR="$DOTS_DIR/themes"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/avionic/theme"
DEFAULT_THEME="magma"

die() { printf 'xx %s\n' "$*" >&2; exit 1; }

themes() {
    local palette
    for palette in "$THEMES_DIR"/*/palette.sh; do
        basename "$(dirname "$palette")"
    done
}

current() {
    local name=""
    [[ -s "$STATE_FILE" ]] && name="$(head -n1 "$STATE_FILE")"
    [[ -n "$name" && -f "$THEMES_DIR/$name/palette.sh" ]] || name="$DEFAULT_THEME"
    printf '%s\n' "$name"
}

usage() { sed -n '3,10p' "${BASH_SOURCE[0]}" | sed -E 's/^# {0,2}//'; }

case "${1:-}" in
    ""|-h|--help)
        usage
        ;;
    list)
        cur="$(current)"
        while read -r name; do
            # shellcheck disable=SC1090
            title="$(source "$THEMES_DIR/$name/palette.sh" && printf '%s' "${theme_name:-$name}")"
            if [[ "$name" == "$cur" ]]; then printf '* %-10s %s\n' "$name" "$title"
            else printf '  %-10s %s\n' "$name" "$title"; fi
        done < <(themes)
        ;;
    current)
        current
        ;;
    *)
        name="$1"
        [[ "$name" =~ ^[A-Za-z0-9_-]+$ && -f "$THEMES_DIR/$name/palette.sh" ]] \
            || die "unknown theme '$name' (have: $(themes | tr '\n' ' '))"
        mkdir -p "$(dirname "$STATE_FILE")"
        printf '%s\n' "$name" >"$STATE_FILE"
        "$DOTS_DIR/scripts/apply-theme.sh" --theme "$name" --reload
        ;;
esac
