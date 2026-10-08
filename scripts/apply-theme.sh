#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  apply-theme.sh — render a theme into every app config.
#
#  Reads   themes/<name>/palette.sh     (one folder per theme)
#  Renders templates/<path>.tmpl -> config/<path>
#          replacing {{key}}, {{color.hex}} and {{color.rgb}} placeholders.
#
#  Usage:  scripts/apply-theme.sh [--theme NAME | --palette FILE] [--reload] [--check]
#    --theme NAME    render themes/NAME (default: the saved choice, see below)
#    --palette FILE  render any palette file instead
#    --reload        also reload running apps (Hyprland, the bar, swaync, kitty…)
#    --check         render into a temp dir only; fail on unknown placeholders.
#                    Without --theme/--palette this checks every theme.
#
#  The saved choice lives in ~/.local/state/avionic/theme (scripts/theme.sh
#  writes it); AVIONIC_THEME overrides it; the default is magma.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail
shopt -s globstar nullglob
shopt -u patsub_replacement 2>/dev/null || true   # keep '&' literal in values

DOTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
THEMES_DIR="$DOTS_DIR/themes"
TEMPLATES="$DOTS_DIR/templates"
OUT_DIR="$DOTS_DIR/config"
STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/avionic/theme"
DEFAULT_THEME="magma"
THEME=""
PALETTE=""
RELOAD=0
CHECK=0

# Every key a palette must define.
COLOR_KEYS=(bg bg_alt surface overlay fg fg_dim muted accent accent_alt urgent warning success danger
            ramp_0 ramp_1 ramp_2 ramp_3 ramp_4 ramp_5
            ansi_0 ansi_1 ansi_2 ansi_3 ansi_4 ansi_5 ansi_6 ansi_7
            ansi_8 ansi_9 ansi_10 ansi_11 ansi_12 ansi_13 ansi_14 ansi_15)
VALUE_KEYS=(theme_name bar font_ui font_mono font_term font_size radius border gaps_in gaps_out
            gtk_theme icon_theme cursor_theme cursor_size lock_date wallpaper)
NUMBER_KEYS=(font_size radius border gaps_in gaps_out cursor_size)

if [[ -t 1 ]]; then c_acc=$'\033[1;38;5;215m' c_warn=$'\033[1;33m' c_err=$'\033[1;31m' c_off=$'\033[0m'
else c_acc="" c_warn="" c_err="" c_off=""; fi
say()  { printf '%s::%s %s\n' "$c_acc" "$c_off" "$*"; }
warn() { printf '%s!!%s %s\n' "$c_warn" "$c_off" "$*" >&2; }
die()  { printf '%sxx%s %s\n' "$c_err" "$c_off" "$*" >&2; exit 1; }

while (($#)); do
    case "$1" in
        --theme) THEME="${2:?--theme needs a name}"; shift ;;
        --theme=*) THEME="${1#*=}" ;;
        --palette) PALETTE="$(readlink -f "${2:?--palette needs a file}")"; shift ;;
        --reload) RELOAD=1 ;;
        --check) CHECK=1 ;;
        -h|--help) sed -n '3,17p' "${BASH_SOURCE[0]}" | sed -E 's/^# {0,2}//'; exit 0 ;;
        *) die "unknown option: $1" ;;
    esac
    shift
done

# --check with no theme given: check every theme, one subprocess each.
if ((CHECK)) && [[ -z "$THEME" && -z "$PALETTE" ]]; then
    found=0
    for palette in "$THEMES_DIR"/*/palette.sh; do
        name="$(basename "$(dirname "$palette")")"
        "${BASH_SOURCE[0]}" --check --theme "$name" || exit 1
        found=1
    done
    ((found)) || die "no themes found in $THEMES_DIR"
    exit 0
fi

if [[ -z "$PALETTE" ]]; then
    if [[ -z "$THEME" ]]; then
        THEME="${AVIONIC_THEME:-}"
        [[ -n "$THEME" || ! -s "$STATE_FILE" ]] || THEME="$(head -n1 "$STATE_FILE")"
        THEME="${THEME:-$DEFAULT_THEME}"
    fi
    [[ "$THEME" =~ ^[A-Za-z0-9_-]+$ ]] || die "invalid theme name: '$THEME'"
    PALETTE="$THEMES_DIR/$THEME/palette.sh"
    if [[ ! -f "$PALETTE" ]]; then
        have=""
        for p in "$THEMES_DIR"/*/palette.sh; do have+="$(basename "$(dirname "$p")") "; done
        die "unknown theme '$THEME' (have: $have)"
    fi
fi
[[ -f "$PALETTE" ]] || die "palette not found: $PALETTE"
PALETTE_DIR="$(dirname "$PALETTE")"

# ── Load palette in a clean scope ───────────────────────────────────────────
# shellcheck source=SCRIPTDIR/../themes/magma/palette.sh
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
[[ "${VARS[wallpaper]}" == /* ]] || VARS[wallpaper]="$PALETTE_DIR/${VARS[wallpaper]}"
[[ -f "${VARS[wallpaper]}" ]] || warn "wallpaper not found: ${VARS[wallpaper]}"
VARS[theme]="$(basename "$PALETTE_DIR")"
[[ -f "$DOTS_DIR/config/quickshell/themes/${VARS[bar]}/Bar.qml" ]] \
    || warn "bar layout '${VARS[bar]}' not found under config/quickshell/themes/"
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
    say "check passed: $count templates render cleanly with ${PALETTE#"$DOTS_DIR"/}"
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
    "$DOTS_DIR/scripts/bar.sh" reload >/dev/null 2>&1 || true        # Quickshell (or Waybar) picks up the theme
    if command -v swaync-client >/dev/null; then swaync-client --reload-css >/dev/null 2>&1 || true; fi
    pkill -SIGUSR1 -x kitty 2>/dev/null || true               # kitty: reload config
    if pgrep -x swayosd-server >/dev/null; then               # swayosd: restart to re-read CSS
        pkill -x swayosd-server || true
        setsid -f swayosd-server >/dev/null 2>&1 || true
    fi
    say "running apps reloaded"
fi
