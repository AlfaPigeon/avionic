#!/usr/bin/env bash
# Pick a color anywhere on screen, copy its hex code, and show it.
set -euo pipefail

color="$(hyprpicker -a -f hex)" || exit 0
[[ -n "$color" ]] || exit 0
notify-send -a "Color picker" "$color" "copied to clipboard"
