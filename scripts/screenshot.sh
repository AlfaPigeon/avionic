#!/usr/bin/env bash
# Screenshots with grim + slurp (+ swappy for editing).
#   screenshot.sh region   select an area  → file + clipboard
#   screenshot.sh screen   focused monitor → file + clipboard
#   screenshot.sh edit     select an area  → swappy editor
set -euo pipefail

mode="${1:-region}"
dir="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")/Screenshots"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
mkdir -p "$dir"

select_region() { slurp -d -b '#00000055' -w 0; }

case "$mode" in
    region)
        geometry="$(select_region)" || exit 0          # Esc cancels quietly
        grim -g "$geometry" "$file"
        ;;
    screen)
        output="$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"
        grim -o "$output" "$file"
        ;;
    edit)
        geometry="$(select_region)" || exit 0
        grim -g "$geometry" - | swappy -f -
        exit 0
        ;;
    *)
        echo "usage: $(basename "$0") region|screen|edit" >&2
        exit 2
        ;;
esac

wl-copy --type image/png <"$file"
notify-send -a Screenshot -i "$file" "Screenshot saved" "${file/#$HOME/\~} · copied to clipboard"
