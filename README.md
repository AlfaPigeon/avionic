# Avionic

A cockpit-instrument Hyprland desktop for Arch Linux. Dark graphite panels, 1px rules, square corners, no blur, and one amber readout: the active workspace and the focused window. Everything else stays quiet. The bar is a custom [Quickshell](https://quickshell.org) instrument strip.

![Avionic wallpaper](assets/wallpapers/avionic.png)

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/AlfaPigeon/avionic/main/install.sh | bash
```

Pass options after `bash -s --`:

```sh
curl -fsSL https://raw.githubusercontent.com/AlfaPigeon/avionic/main/install.sh | bash -s -- --sddm --shell fish
```

| Option | What it does |
| --- | --- |
| `--no-packages` | Skip pacman/AUR. Only link configs and apply the theme |
| `--sddm` | Install and enable SDDM (off by default) |
| `--waybar` | Use Waybar as the bar instead of Quickshell (installs `waybar`, links its config, autostarts it) |
| `--wlogout` | Use wlogout (AUR) as the power menu instead of the built-in rofi one |
| `--shell fish\|zsh` | Install that shell and make it your login shell (off by default) |
| `--dry-run` | Print every step, change nothing |
| `-y`, `--yes` | Accept defaults without asking |

> **Heads-up:** the package step runs `sudo pacman -Syu --needed …`, so it **upgrades your whole system** before installing (Arch does not support partial upgrades). Use `--no-packages` to skip it, or `--dry-run` to see every command first.

The installer refuses to run as root and checks for pacman. It installs from the official repos only, clones the repo to `~/.local/share/avionic` (or updates it), backs up existing configs to `~/.local/state/avionic/backups/<timestamp>/`, and symlinks ours into `~/.config`, so `git pull` updates them. It also enables PipeWire, NetworkManager and Bluetooth. You can run it again safely.

Start the desktop with `start-hyprland` on a TTY, or pick **Hyprland** in SDDM.

## Targets

Built for **Hyprland 0.56.2**, which uses the **Lua config** (`hyprland.lua`). The old `hyprland.conf` format is deprecated. Hyprland-side syntax used here:

- `hl.window_rule` / `hl.layer_rule` with `match = { … }` (not `windowrulev2`)
- `hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })` (not `workspace_swipe`)
- `hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'` (Lua dispatchers) in hypridle and the power menu
- Quickshell detects the Lua config: on start it asks Hyprland `j/status`, sees `"configProvider": "lua"`, and from then on `HyprlandWorkspace.activate()` sends `hl.dsp.focus({ workspace = "N" })` instead of the old `workspace N`. This landed in Quickshell 0.3.0; Arch ships 0.3.1 in `extra`. The bar uses that for existing workspaces and builds the same Lua dispatch itself for empty ones and for scrolling (`"e+1"` / `"e-1"`).
- The `--waybar` fallback uses Waybar's generic `ext/workspaces` module, because Waybar 0.15's `hyprland/workspaces` still sends old-style dispatches that the Lua config rejects (clicking a workspace would do nothing). Once a Waybar release ships the Lua-compatible fix, switch back to `hyprland/workspaces` in `config/waybar/config.jsonc` (the CSS already targets `#workspaces`).

The other tools are Quickshell 0.3.1, hyprlock 0.9, hypridle 0.1.8, hyprpaper 0.8 (`wallpaper { }` blocks), hyprpolkitagent 0.2, Waybar 0.15 (optional), rofi 2.0 (native Wayland), swaync 0.12 and swayosd 0.3.

## What's included

| Area | Tool |
| --- | --- |
| Compositor | Hyprland, xdg-desktop-portal-hyprland + gtk, hyprpolkitagent |
| Bar | Quickshell (default, see below) or Waybar with `--waybar` |
| Launcher, menus | rofi: apps, clipboard, power menu, keybind list |
| Notifications | swaync (SUPER + N) |
| On-screen display | swayosd for volume and brightness keys |
| Lock & idle | hyprlock + hypridle: dim 2.5 min, lock 5 min, screen off 5.5 min, suspend 30 min |
| Wallpaper | hyprpaper, Designer's `assets/wallpapers/avionic.png` (SVG source alongside), also the lock screen background |
| Terminal | kitty |
| Files | Thunar (+ gvfs, archive and volume plugins) |
| Screenshots | grim + slurp, swappy for edits, saved to `~/Pictures/Screenshots` and copied |
| Clipboard | cliphist + wl-clipboard |
| Color picker | hyprpicker |
| Media | playerctl, brightnessctl, wpctl/WirePlumber, pavucontrol |
| Network | NetworkManager + nm-applet, BlueZ + Blueman |
| Look | GTK (adw-gtk3 + nwg-look), Qt (qt6ct, qt5/qt6-wayland), Papirus icons, IBM Plex Sans (UI) + JetBrainsMono Nerd Font (bar, terminal, readouts) |

## The bar

`config/quickshell/` is a small Quickshell config (plain QML, no scripts) that draws one bar per screen:

| Part | What it shows | Mouse |
| --- | --- | --- |
| Heading tape | Workspaces 01–10 (more if you use them) on a tick tape. The active one on that screen is amber with a caret and underline; occupied ones are in text color, empty ones muted, urgent ones red | Click to switch, scroll for next/previous |
| Window title | The focused window, muted | |
| Clock | A 12-tick ring with a seconds dot, `HH:MM`, and the date | |
| Gauges | Thin 270° arcs for CPU and memory (from `/proc`) and battery (UPower, hidden on desktops). Track `#232A31`, value in text color, red only when critical (≥ 90% load, ≤ 12% battery) | Click opens btop |
| Audio | Default output volume (PipeWire) | Scroll to change, right-click to mute, click for pavucontrol |
| Network | SSID, ETH or OFFLINE (NetworkManager) | Click for nm-connection-editor |
| Bluetooth | Off / on / connected count (BlueZ) | Click for blueman |
| Tray | StatusNotifier icons | Click activates, right-click opens the app menu |
| Notifications | swaync state and count | Click toggles the panel, right-click do-not-disturb |
| Power | Power menu | Click |

Colors and fonts come from `config/quickshell/Theme.qml`, which `apply-theme.sh` generates from the palette. `scripts/bar.sh start|restart|reload` starts whichever bar you chose (recorded in `~/.local/state/avionic/bar`; `AVIONIC_BAR=waybar` overrides it). Quickshell also reloads by itself when its files change.

## Keybinds

`SUPER + F1` shows every bind in a searchable list.

| Keys | Action |
| --- | --- |
| `SUPER + Return` | Terminal |
| `SUPER + Space` | App launcher |
| `SUPER + E` | File manager |
| `SUPER + V` | Clipboard history |
| `SUPER + N` / `SUPER + SHIFT + N` | Notification center / do not disturb |
| `SUPER + L` | Lock |
| `SUPER + Escape` | Power menu |
| `SUPER + Q` | Close window |
| `SUPER + F` / `SUPER + M` | Fullscreen / maximize |
| `SUPER + T` | Toggle floating |
| `SUPER + C` | Center floating window |
| `SUPER + P` / `SUPER + J` | Pseudo-tile / toggle split |
| `SUPER + G` / `SUPER + Tab` | Toggle group / next in group |
| `SUPER + R` | Resize mode (arrows, Esc to leave) |
| `SUPER + ←↑→↓` | Move focus |
| `SUPER + SHIFT + ←↑→↓` | Move window |
| `SUPER + CTRL + ←↑→↓` | Swap window |
| `SUPER + 1…0` | Go to workspace 1–10 |
| `SUPER + SHIFT + 1…0` | Move window to workspace |
| `SUPER + ALT + 1…0` | Send window to workspace, stay here |
| `SUPER + [` / `]`, `SUPER + scroll` | Previous / next workspace |
| `SUPER + S` / `SUPER + SHIFT + S` | Scratchpad / move window there |
| `SUPER + drag` / `SUPER + right-drag` | Move / resize window |
| `Print` / `SHIFT + Print` | Screenshot area / screen |
| `SUPER + Print` | Screenshot area into the editor |
| `SUPER + SHIFT + C` | Color picker |
| `SUPER + SHIFT + R` / `SUPER + SHIFT + B` | Reload Hyprland / restart the bar |
| Media keys | Volume, mic, brightness (with OSD), play/pause/next/prev |

The keyboard layout is set at the top of `config/hypr/hyprland.lua` (default `us`, use `tr` for Turkish). Put monitors and anything machine-specific in `~/.config/hypr/user.lua` (see `user.lua.example`).

## Theme

Everything visual comes from **one file: `theme/palette.sh`**. It holds 15 colors (6-digit hex), two fonts, a size, radius, border, gaps, the GTK/icon/cursor theme names and the wallpaper path. The Avionic defaults:

| Role | Key | Value |
| --- | --- | --- |
| Background | `bg` | `#0C0E11` |
| Bar / panels | `bg_alt` | `#101317` |
| Surface | `surface` | `#15191E` |
| Border (every rule) | `overlay` | `#232A31` |
| Text / secondary / muted | `fg` / `fg_dim` / `muted` | `#E8E4DA` / `#B1B4B4` / `#7A848F` |
| Amber accent (active workspace, focused border) | `accent` | `#FFB347` |
| Info, used sparingly | `accent_alt` | `#7FB7D9` |
| Warning / urgent | `warning`, `urgent` | `#F25C54` |
| Quiet status and terminal tones | `success`, `ansi_*` | sage, ochre, violet, teal |
| Fonts | `font_ui`, `font_mono` | IBM Plex Sans, JetBrainsMono Nerd Font |
| Shape | `radius`, `border` | `0`, `1` |

```sh
$EDITOR ~/.local/share/avionic/theme/palette.sh
~/.local/share/avionic/scripts/apply-theme.sh --reload
```

`apply-theme.sh` renders every `theme/templates/<app>/<file>.tmpl` into `config/<app>/<file>`. Rendered files are git-ignored. Templates use:

- `{{name}}` for any palette value, for example `{{font_ui}}` or `{{radius}}`
- `{{color}}` → `#0c0e11`, `{{color.hex}}` → `0c0e11`, `{{color.rgb}}` → `12, 14, 17`

Unknown placeholders and malformed colors fail loudly. `--check` renders into a temp dir as a dry run. To restyle a component, edit its template. To recolor everything, edit only the palette. Optional: `scripts/make-wallpaper.sh` draws a simple abstract wallpaper from the palette (needs ImageMagick) into `assets/wallpapers/generated.png`; point `wallpaper=` at it if you want it.

## Layout

```
install.sh  uninstall.sh
config/<app>/        static configs, symlinked into ~/.config (+ rendered theme files)
config/quickshell/   the bar (QML)
theme/palette.sh     the single source of truth
theme/templates/     themed files with {{placeholders}}
scripts/             apply-theme, bar, screenshots, clipboard, power menu, keybind list, links.conf
assets/wallpapers/   avionic.png (default) + avionic.svg
```

## Uninstall

```sh
~/.local/share/avionic/uninstall.sh
```

This removes only the symlinks that point into the repo and restores the most recent backup. Packages, services and the repo stay. The script prints how to remove the repo.

## License

[MIT](LICENSE) © 2026 AlfaPigeon
