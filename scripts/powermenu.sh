#!/usr/bin/env bash
# Power menu: wlogout if it is installed and configured, otherwise rofi.
set -euo pipefail

logout_cmd() {
    if command -v hyprshutdown >/dev/null 2>&1; then
        hyprshutdown
    else
        hyprctl dispatch 'hl.dsp.exit()'
    fi
}

if command -v wlogout >/dev/null 2>&1 && [[ -f "$HOME/.config/wlogout/layout" ]]; then
    exec wlogout --protocol layer-shell --buttons-per-row 5 --column-spacing 12 --row-spacing 12
fi

confirm() {
    local answer
    answer="$(printf 'No\nYes\n' | rofi -dmenu -i -p "$1?" -theme-str 'window { width: 300px; } listview { lines: 2; }')" || return 1
    [[ "$answer" == "Yes" ]]
}

entries=(
    "󰌾  Lock"
    "󰤄  Suspend"
    "󰍃  Log out"
    "󰜉  Reboot"
    "󰐥  Shut down"
)

choice="$(printf '%s\n' "${entries[@]}" \
    | rofi -dmenu -i -p "power" -theme-str 'window { width: 300px; } listview { lines: 5; }')" || exit 0

case "$choice" in
    *Lock)      loginctl lock-session ;;
    *Suspend)   systemctl suspend ;;
    *"Log out") confirm "Log out" && logout_cmd ;;
    *Reboot)    confirm "Reboot" && systemctl reboot ;;
    *"Shut down") confirm "Shut down" && systemctl poweroff ;;
esac
