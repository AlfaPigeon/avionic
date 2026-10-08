#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  apply-theme.sh — render the theme into every app config.
#
#  Reads   theme/palette.sh            (the single source of truth)
#  Renders theme/templates/<path>.tmpl -> config/<path>
#          replacing {{key}}, {{color.hex}} and {{color.rgb}} placeholders.
#
#  Usage:  scripts/apply-theme.sh [--reload] [--check] [--palette FILE]
#    --reload        also reload running apps (Hyprland, Waybar, swaync, kitty…)
#    --check         render into a temp dir only; fail on unknown placeholders
#    --palette FILE  use another palette file (default: theme/palette.sh)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
shopt -s globstar nullglob
shopt -u patsub_replacement 2>/dev/null || true   # keep '&' literal in values

DOTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
PALETTE="$DOTS_DIR/theme/palette.sh"
TEMPLATES="$DOTS_DIR/theme/templates"
OUT_DIR="$DOTS_DIR/config"
RELOAD=0
CHECK=0

# Every key a palette must define. Designer's palette fills exactly these.
COLOR_KEYS=(bg bg_alt surface overlay fg fg_dim muted accent accent_alt urgent warning success
            ansi_yellow ansi_magenta ansi_cyan)
VALUE_KEYS=(theme_name font_ui font_mono font_size radius border gaps_in gaps_out
            gtk_theme icon_theme cursor_theme cursor_size wallpaper)
NUMBER_KEYS=(font_size radius border gaps_in gaps_out cursor_size)

if [[ -t 1 ]]; then c_acc=$'\033[1;36m' c_warn=$'\033[1;33m' c_err=$'\033[1;31m' c_off=$'\033[0m'
else c_acc="" c_warn="" c_err="" c_off=""; fi
say()  { printf '%s::%s %s\n' "$c_acc" "$c_off" "$*"; }
warn() { printf '%s!!%s %s\n' "$c_warn" "$c_off" "$*" >&2; }
die()  { printf '%sxx%s %s\n' "$c_err" "$c_off" "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --reload) RELOAD=1 ;;
        --check) CHECK=1 ;;
        --palette) PALETTE="$(readlink -f "${2:?--palette needs a file}")"; shift ;;
        -h|--help) sed -n '3,12p' "${BASH_SOURCE[0]}" | sed -E 's/^# {0,2}//'; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

[[ -f "$PALETTE" ]] || die "palette not found: $PALETTE"

# ── Load palette in a clean scope ───────────────────────────────────────────
# shellcheck source=SCRIPTDIR/../theme/palette.sh
source "$PALETTE"

declare -A VARS=()
for key in "${COLOR_KEYS[@]}"; do
    value="${!key:-}"
    value="${value#\#}"
    [[ "$value" =~ ^[0-9a-fA-F]{6}$ ]] || die "palette: '$key' must be 6-digit hex, got '${value}'"
    value="${value,,}"
    VARS[$key]="#$value"
    VARS[$key.hex]="$value"
    VARS[$key.rgb]="$((16#${value:0:2})), $((16#${value:2:2})), $((16#${value:4:2}))"
done
for key in "${VALUE_KEYS[@]}"; do
    [[ -n "${!key:-}" ]] || die "palette: '$key' is missing or empty"
    VARS[$key]="${!key}"
done
for key in "${NUMBER_KEYS[@]}"; do
    [[ "${VARS[$key]}" =~ ^[0-9]+$ ]] || die "palette: '$key' must be a whole number"
done

# Derived values
[[ "${VARS[wallpaper]}" == /* ]] || VARS[wallpaper]="$DOTS_DIR/${VARS[wallpaper]}"
[[ -f "${VARS[wallpaper]}" ]] || warn "wallpaper not found: ${VARS[wallpaper]}"
VARS[home]="$HOME"
VARS[dots_dir]="$DOTS_DIR"

# ── Render ──────────────────────────────────────────────────────────────────
render() { # render <template> <output>
    local tmpl="$1" out="$2" content key leftovers
    content="$(<"$tmpl")"
    for key in "${!VARS[@]}"; do
        content="${content//"{{$key}}"/"${VARS[$key]}"}"
    done
    leftovers="$(grep -oE '\{\{[A-Za-z0-9_.]+\}\}' <<<"$content" | sort -u | tr '\n' ' ' || true)"
    [[ -z "$leftovers" ]] || die "${tmpl#"$DOTS_DIR"/}: unknown placeholder(s): $leftovers"
    mkdir -p "$(dirname "$out")"
    printf '%s\n' "$content" >"$out.tmp.$$"
    mv -f "$out.tmp.$$" "$out"
}

if ((CHECK)); then
    OUT_DIR="$(mktemp -d)"
    trap 'rm -rf "$OUT_DIR"' EXIT
fi

count=0
for tmpl in "$TEMPLATES"/**/*.tmpl; do
    rel="${tmpl#"$TEMPLATES"/}"
    render "$tmpl" "$OUT_DIR/${rel%.tmpl}"
    count=$((count + 1))
done
((count > 0)) || die "no templates found in $TEMPLATES"

if ((CHECK)); then
    say "check passed: $count templates render cleanly with $(basename "$PALETTE")"
    exit 0
fi
say "theme '${VARS[theme_name]}' rendered into $count files under config/"

# ── Desktop settings that live outside files (GTK4/libadwaita read these) ───
if command -v gsettings >/dev/null 2>&1 && [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    gs() { gsettings set org.gnome.desktop.interface "$@" 2>/dev/null || true; }
    gs color-scheme 'prefer-dark'
    gs gtk-theme "${VARS[gtk_theme]}"
    gs icon-theme "${VARS[icon_theme]}"
    gs cursor-theme "${VARS[cursor_theme]}"
    gs cursor-size "${VARS[cursor_size]}"
    gs font-name "${VARS[font_ui]} ${VARS[font_size]}"
    gs monospace-font-name "${VARS[font_mono]} ${VARS[font_size]}"
fi

# ── Live reload ─────────────────────────────────────────────────────────────
if ((RELOAD)); then
    if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null; then
        hyprctl reload >/dev/null || true
        hyprctl setcursor "${VARS[cursor_theme]}" "${VARS[cursor_size]}" >/dev/null 2>&1 || true
        hyprctl hyprpaper wallpaper ",${VARS[wallpaper]}" >/dev/null 2>&1 || true
    fi
    pkill -SIGUSR2 -x waybar 2>/dev/null || true              # waybar: reload style
    if command -v swaync-client >/dev/null; then swaync-client --reload-css >/dev/null 2>&1 || true; fi
    pkill -SIGUSR1 -x kitty 2>/dev/null || true               # kitty: reload config
    if pgrep -x swayosd-server >/dev/null; then               # swayosd: restart to re-read CSS
        pkill -x swayosd-server || true
        setsid -f swayosd-server >/dev/null 2>&1 || true
    fi
    say "running apps reloaded"
fi
