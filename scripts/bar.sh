#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Start, restart or reload the Avionic bar.
#
#  Usage: bar.sh [start|restart|reload|which]
#
#  The bar is Quickshell (~/.config/quickshell) unless the installer was run
#  with --waybar, which records "waybar" in ~/.local/state/avionic/bar.
#  AVIONIC_BAR=waybar|quickshell overrides the recorded choice.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

choice_file="${XDG_STATE_HOME:-$HOME/.local/state}/avionic/bar"

bar="${AVIONIC_BAR:-}"
[[ -n "$bar" ]] || bar="$(cat "$choice_file" 2>/dev/null || true)"
[[ "$bar" == waybar ]] || bar=quickshell

# Fall back to whichever bar is actually installed.
if [[ "$bar" == quickshell ]] && ! command -v qs >/dev/null 2>&1 && command -v waybar >/dev/null 2>&1; then
    bar=waybar
elif [[ "$bar" == waybar ]] && ! command -v waybar >/dev/null 2>&1 && command -v qs >/dev/null 2>&1; then
    bar=quickshell
fi

stop_all() {
    pkill -x waybar 2>/dev/null || true
    pkill -x quickshell 2>/dev/null || true
    pkill -x qs 2>/dev/null || true
}

start() {
    case "$bar" in
        waybar)     setsid -f waybar >/dev/null 2>&1 ;;
        quickshell) setsid -f qs >/dev/null 2>&1 ;;
    esac
}

case "${1:-start}" in
    start)
        pgrep -x "$( [[ "$bar" == waybar ]] && echo waybar || echo 'quickshell|qs')" >/dev/null 2>&1 || start ;;
    restart)
        stop_all
        sleep 0.3
        start ;;
    reload)
        # Quickshell also live-reloads on file changes; this makes it explicit.
        if [[ "$bar" == quickshell ]]; then
            qs ipc call avionic reload >/dev/null 2>&1 || { stop_all; sleep 0.3; start; }
        else
            pkill -SIGUSR2 -x waybar 2>/dev/null || true
        fi ;;
    which)
        echo "$bar" ;;
    *)
        sed -n '3,10p' "${BASH_SOURCE[0]}" | sed -E 's/^# {0,2}//'
        exit 1 ;;
esac
