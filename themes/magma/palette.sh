# shellcheck shell=bash
# shellcheck disable=SC2034  # variables are read by scripts/apply-theme.sh
# ─────────────────────────────────────────────────────────────────────────────
#  MAGMA — every color, font and size of the Magma theme.
#
#  A live notebook cell: violet-black base, matplotlib's magma heat ramp
#  (deep purple -> rose -> pale yellow), IBM Plex Mono everywhere. Rose is
#  the accent (focused border, focused app name, cpu sparkline); pale yellow
#  (#fcfdbf, the top of the colormap) means "off the scale" and is reserved
#  for urgent and critical states. No green. After editing, run:
#      scripts/theme.sh magma          (or scripts/apply-theme.sh --reload)
#
#  Colors are 6-digit hex WITHOUT '#'. Templates can use each color as:
#    {{bg}}      -> #0b0912        (CSS, rasi, kitty, qt)
#    {{bg.hex}}  -> 0b0912         (Hyprland / hyprlang: rgb({{bg.hex}}))
#    {{bg.rgb}}  -> 11, 9, 18      (CSS rgba({{bg.rgb}}, 0.8))
# ─────────────────────────────────────────────────────────────────────────────

theme_name="Magma"
bar="magma"         # Quickshell bar layout: config/quickshell/themes/<bar>/Bar.qml

# Base layers (darkest -> lightest)
bg="0b0912"         # background: violet-black
bg_alt="100d1a"     # bar and panels
surface="181426"    # menus, inputs, hovered rows
overlay="2a2340"    # border: every rule and outline, inactive window border

# Text
fg="ece6f2"         # text
fg_dim="b9b1c9"     # secondary text, window titles
muted="8a82a0"      # labels (lowercase, like variable names), hints

# Accent
accent="de4968"     # magma rose: focused border, focused app name, cpu sparkline
accent_alt="9a7bff" # info: violet, sparingly (links, auth check)

# Status: "hot" is the top of the colormap, off the scale
urgent="fcfdbf"     # urgent workspace, critical readings, failed auth
warning="fcfdbf"    # low battery, caps lock
success="fe9f6d"    # charging / connected (ramp_4; there is no green)
danger="de4968"     # destructive actions (shutdown button hover)

# Data ramp, low to high (matplotlib magma): heatmap, histograms, gauges
ramp_0="2a2340"
ramp_1="3b0f70"
ramp_2="8c2981"
ramp_3="de4968"
ramp_4="fe9f6d"
ramp_5="fcfdbf"

# Terminal 16-color ANSI palette, taken from the ramp. Every pair of the 16
# stays at least ~12 CIEDE2000 apart, so ls/git/diff colors remain distinct.
ansi_0="181426"     # black (surface)
ansi_1="de4968"     # red: rose
ansi_2="fecf92"     # green: magma 0.9 sand (no green in this theme)
ansi_3="fe9f6d"     # yellow: magma 0.8 peach
ansi_4="9a7bff"     # blue: info violet
ansi_5="c2468f"     # magenta: orchid
ansi_6="d39af2"     # cyan: lilac
ansi_7="b9b1c9"     # white
ansi_8="8a82a0"     # bright black (comments, autosuggestions)
ansi_9="f2708a"
ansi_10="fde6ae"
ansi_11="ffb98a"
ansi_12="b9a1ff"
ansi_13="e66fb3"
ansi_14="eac2ff"
ansi_15="ece6f2"

# Typography (fontconfig family names)
font_ui="IBM Plex Mono"               # ttf-ibm-plex: monospace everywhere, including UI
font_mono="IBM Plex Mono"             # bar readouts
font_term="JetBrainsMono Nerd Font"   # ttf-jetbrains-mono-nerd: terminal and glyph fallback
font_size="11"                        # base UI size in pt

# Shape & spacing (logical px): square corners, 1px rules, no blur
radius="0"
border="1"
gaps_in="4"
gaps_out="8"

# Desktop look (names of installed themes)
gtk_theme="adw-gtk3-dark"
icon_theme="Papirus-Dark"
cursor_theme="Adwaita"
cursor_size="24"

# Lock screen date line (shell command run by hyprlock): ISO date
lock_date="date +%F"

# Wallpaper: path relative to this file, or absolute
wallpaper="wallpaper.png"
