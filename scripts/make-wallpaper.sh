#!/usr/bin/env bash
# OPTIONAL: generate a simple abstract wallpaper from the palette (needs ImageMagick).
# The default wallpaper is Designer's assets/wallpapers/avionic.png; this is only
# for experimenting with other palettes.
#   scripts/make-wallpaper.sh [output.png] [WIDTHxHEIGHT]
# Default output: assets/wallpapers/generated.png (git-ignored) at 3840x2160.
set -euo pipefail

DOTS_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
out="${1:-$DOTS_DIR/assets/wallpapers/generated.png}"
size="${2:-3840x2160}"
w="${size%x*}"; h="${size#*x}"

# shellcheck source=SCRIPTDIR/../theme/palette.sh
source "$DOTS_DIR/theme/palette.sh"

if command -v magick >/dev/null 2>&1; then im=(magick); else im=(convert); fi
command -v "${im[0]}" >/dev/null 2>&1 || { echo "ImageMagick not found" >&2; exit 1; }

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
s=$((w / 1920))      # scale factor for strokes (1 at 1080p, 2 at 4K)
((s >= 1)) || s=1
cell=$((48 * s))
cx=$((w * 70 / 100)); cy=$((h * 42 / 100)); r=$((h * 34 / 100))

# 1. Graphite base: soft light pool behind the ring, falling off to the background color.
"${im[0]}" -size "${w}x${h}" \
    -define gradient:center="${cx},${cy}" -define gradient:radii="$((w * 60 / 100)),$((h * 80 / 100))" \
    radial-gradient:"#${surface}-#${bg}" "$tmp/base.png"

# 2. Faint engineering grid that fades toward the edges.
"${im[0]}" -size "${cell}x${cell}" xc:none -stroke "#${overlay}" -strokewidth "$s" \
    -draw "line 0,0 $((cell - 1)),0" -draw "line 0,0 0,$((cell - 1))" "$tmp/cell.png"
"${im[0]}" -size "${w}x${h}" tile:"$tmp/cell.png" "$tmp/grid.png"
"${im[0]}" -size "${w}x${h}" \
    -define gradient:center="${cx},${cy}" -define gradient:radii="$((w * 45 / 100)),$((h * 70 / 100))" \
    radial-gradient:"gray(40%)-black" "$tmp/fade.png"
"${im[0]}" "$tmp/grid.png" "$tmp/fade.png" -alpha off -compose CopyOpacity -composite "$tmp/grid-faded.png"

# 3. One accent ring (sonar-like sweep) with a soft glow and a short bright arc.
"${im[0]}" -size "${w}x${h}" xc:none -fill none \
    -stroke "#${accent}" -strokewidth "$((2 * s))" -draw "circle ${cx},${cy} $((cx + r)),${cy}" \
    -channel A -evaluate multiply 0.35 +channel "$tmp/ring.png"
"${im[0]}" -size "${w}x${h}" xc:none -fill none \
    -stroke "#${accent}" -strokewidth "$((3 * s))" -draw "arc $((cx - r)),$((cy - r)) $((cx + r)),$((cy + r)) 200,250" \
    "$tmp/arc.png"
"${im[0]}" "$tmp/arc.png" -blur "0x$((14 * s))" "$tmp/glow.png"
"${im[0]}" -size "${w}x${h}" xc:none -fill none \
    -stroke "#${overlay}" -strokewidth "$s" -draw "circle ${cx},${cy} $((cx + r * 62 / 100)),${cy}" \
    "$tmp/inner.png"

# 4. Compose.
"${im[0]}" "$tmp/base.png" \
    "$tmp/grid-faded.png" -compose over -composite \
    "$tmp/inner.png" -compose over -composite \
    "$tmp/ring.png" -compose over -composite \
    "$tmp/glow.png" -compose screen -composite \
    "$tmp/arc.png" -compose over -composite \
    -depth 8 -strip "$out"

echo "wallpaper written: $out ($size)"
