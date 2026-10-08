-- ════════════════════════════════════════════════════════════════════════════
--  Avionic · Hyprland config  ·  targets Hyprland 0.56 (Lua config)
--  Docs: https://wiki.hypr.land/Configuring/
--
--  Colors, gaps, fonts and cursor come from ./theme.lua, which is generated
--  from themes/<name>/palette.sh by scripts/apply-theme.sh. Do not hard-code colors here.
--
--  Machine-specific tweaks (monitors, extra binds, layouts…) go in
--  ~/.config/hypr/user.lua. It is git-ignored and loaded last, if it exists.
-- ════════════════════════════════════════════════════════════════════════════

----------------------
---- QUICK CONFIG ----
----------------------

-- Keyboard layout. Examples: "us", "tr", or "us,tr" with kb_options below.
local kb_layout  = "us"            -- Turkish Q: "tr"
local kb_variant = ""              -- Turkish F: kb_layout = "tr", kb_variant = "f"
local kb_options = ""              -- e.g. "grp:alt_shift_toggle" to switch "us,tr"

local terminal    = "kitty"
local fileManager = "thunar"
local launcher    = "rofi -show drun"
local scripts     = "~/.config/hypr/scripts"   -- links to the repo's scripts/ dir

local mainMod = "SUPER"


---------------
---- THEME ----
---------------

-- Fallback values (Magma, the default theme) keep Hyprland usable if
-- apply-theme has not run yet.
local ok, theme = pcall(require, "theme")
if not ok or type(theme) ~= "table" or not theme.accent then
    theme = {
        bg = "0b0912", bg_alt = "100d1a", surface = "181426", overlay = "2a2340",
        accent = "de4968", font_ui = "IBM Plex Mono",
        radius = 0, border = 1, gaps_in = 4, gaps_out = 8,
        cursor_theme = "Adwaita", cursor_size = 24,
    }
end

local function rgba(hex, alpha) return "rgba(" .. hex .. (alpha or "ff") .. ")" end


------------------
---- MONITORS ----
------------------

-- Every monitor: preferred mode, auto position, auto scale.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Example (run `hyprctl monitors` for names). Put real ones in user.lua:
-- hl.monitor({ output = "DP-1",  mode = "2560x1440@165", position = "0x0",    scale = 1 })
-- hl.monitor({ output = "eDP-1", mode = "preferred",     position = "2560x0", scale = 1.25 })


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME",    theme.cursor_theme)
hl.env("XCURSOR_SIZE",     tostring(theme.cursor_size))
hl.env("HYPRCURSOR_THEME", theme.cursor_theme)
hl.env("HYPRCURSOR_SIZE",  tostring(theme.cursor_size))

hl.env("QT_QPA_PLATFORM",       "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME",  "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_BACKEND",           "wayland,x11,*")
hl.env("SDL_VIDEODRIVER",       "wayland")
hl.env("CLUTTER_BACKEND",       "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd(scripts .. "/bar.sh start")      -- Quickshell, or Waybar if installed with --waybar
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("hyprctl setcursor " .. theme.cursor_theme .. " " .. theme.cursor_size)
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = theme.gaps_in,
        gaps_out    = theme.gaps_out,
        border_size = theme.border,
        -- Amber marks the focused window; everything else is a quiet 1px rule.
        col = {
            active_border   = rgba(theme.accent),
            inactive_border = rgba(theme.overlay),
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    -- Flat instrument panel: square corners, no shadows, no blur, no transparency.
    decoration = {
        rounding         = theme.radius,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    group = {
        col = {
            border_active   = rgba(theme.accent),
            border_inactive = rgba(theme.overlay),
        },
        groupbar = {
            font_family = theme.font_ui,
            rounding    = theme.radius,
            col = {
                active   = rgba(theme.surface),
                inactive = rgba(theme.bg_alt),
            },
        },
    },

    animations = { enabled = true },

    dwindle = { preserve_split = true },
    master  = { new_status = "master" },

    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        background_color         = rgba(theme.bg),
        focus_on_activate        = true,
        enable_swallow           = true,
        swallow_regex            = "^(kitty)$",
        font_family              = theme.font_ui,
    },

    cursor = { hide_on_key_press = false },
})

-- Animations: short and precise, nothing bouncy.
hl.curve("smooth",   { type = "bezier", points = { {0.25, 1},   {0.5, 1}  } })
hl.curve("snappy",   { type = "bezier", points = { {0.2, 0.9},  {0.1, 1}  } })
hl.curve("linear",   { type = "bezier", points = { {0, 0},      {1, 1}    } })
hl.curve("soft",     { type = "spring", mass = 1, stiffness = 260, dampening = 28 })

hl.animation({ leaf = "global",        enabled = true, speed = 8,   bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.5, spring = "soft" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,   spring = "soft",  style = "popin 92%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.6, bezier = "linear", style = "popin 92%" })
hl.animation({ leaf = "border",        enabled = true, speed = 5,   bezier = "smooth" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3,   bezier = "snappy" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,   bezier = "smooth", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3,   bezier = "smooth", style = "slidefade 12%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth", style = "slidevert" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = kb_layout,
        kb_variant = kb_variant,
        kb_options = kb_options,

        follow_mouse = 1,
        sensitivity  = 0,            -- -1.0 … 1.0, 0 = no change
        repeat_rate  = 35,
        repeat_delay = 300,

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
        },
    },
})

-- Three-finger horizontal swipe switches workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })


---------------------
---- KEYBINDINGS ----
---------------------
-- Every bind has a description: SUPER + F1 shows them all in a searchable list.

local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end
local function key(k) return mainMod .. " + " .. k end
local exec = hl.dsp.exec_cmd

-- Apps
bind(key("Return"),         exec(terminal),                          "Terminal")
bind(key("space"),          exec(launcher),                          "App launcher")
bind(key("E"),              exec(fileManager),                       "File manager")
bind(key("V"),              exec(scripts .. "/clipboard.sh"),        "Clipboard history")
bind(key("N"),              exec("swaync-client -t -sw"),            "Notification center")
bind(key("SHIFT + N"),      exec("swaync-client -d -sw"),            "Toggle do-not-disturb")
bind(key("F1"),             exec(scripts .. "/keybinds.sh"),         "Show keybinds")

-- Session
bind(key("L"),              exec("loginctl lock-session"),           "Lock screen")
bind(key("Escape"),         exec(scripts .. "/powermenu.sh"),        "Power menu")
bind(key("SHIFT + R"),      exec("hyprctl reload"),                  "Reload Hyprland config")
bind(key("SHIFT + B"),      exec(scripts .. "/bar.sh restart"),      "Restart the bar")

-- Windows
bind(key("Q"),              hl.dsp.window.close(),                               "Close window")
bind(key("F"),              hl.dsp.window.fullscreen(),                          "Fullscreen")
bind(key("M"),              hl.dsp.window.fullscreen({ mode = "maximized" }),    "Maximize")
bind(key("T"),              hl.dsp.window.float({ action = "toggle" }),          "Toggle floating")
bind(key("C"),              hl.dsp.window.center(),                              "Center floating window")
bind(key("P"),              hl.dsp.window.pseudo(),                              "Pseudo-tile")
bind(key("J"),              hl.dsp.layout("togglesplit"),                        "Toggle split direction")
bind(key("G"),              hl.dsp.group.toggle(),                               "Toggle group")
bind(key("Tab"),            hl.dsp.group.next(),                                 "Next window in group")
bind(key("R"),              hl.dsp.submap("resize"),                             "Resize mode (arrows, Esc to exit)")

for _, dir in ipairs({ "left", "right", "up", "down" }) do
    bind(key(dir),              hl.dsp.focus({ direction = dir }),       "Focus " .. dir)
    bind(key("SHIFT + " .. dir), hl.dsp.window.move({ direction = dir }), "Move window " .. dir)
    bind(key("CTRL + " .. dir),  hl.dsp.window.swap({ direction = dir }), "Swap window " .. dir)
end

-- Mouse: SUPER + drag moves, SUPER + right-drag resizes
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Resize submap
hl.define_submap("resize", function()
    local step = 30
    hl.bind("right", hl.dsp.window.resize({ x =  step, y = 0, relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0, y =  step, relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0, y = -step, relative = true }), { repeating = true })
    hl.bind("Escape", hl.dsp.submap("reset"))
    hl.bind("Return", hl.dsp.submap("reset"))
end)

-- Workspaces 1-10 (key 0 = workspace 10)
for i = 1, 10 do
    local k = tostring(i % 10)
    bind(key(k),              hl.dsp.focus({ workspace = i }),                         "Go to workspace " .. i)
    bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }),                  "Move window to workspace " .. i)
    bind(key("ALT + " .. k),   hl.dsp.window.move({ workspace = i, follow = false }),  "Send window to workspace " .. i .. " (silent)")
end
bind(key("mouse_down"),     hl.dsp.focus({ workspace = "e+1" }),                 "Next workspace")
bind(key("mouse_up"),       hl.dsp.focus({ workspace = "e-1" }),                 "Previous workspace")
bind(key("bracketright"),   hl.dsp.focus({ workspace = "e+1" }),                 "Next workspace")
bind(key("bracketleft"),    hl.dsp.focus({ workspace = "e-1" }),                 "Previous workspace")

-- Scratchpad
bind(key("S"),              hl.dsp.workspace.toggle_special("scratch"),          "Toggle scratchpad")
bind(key("SHIFT + S"),      hl.dsp.window.move({ workspace = "special:scratch" }), "Move window to scratchpad")

-- Screenshots & color picker
bind("Print",               exec(scripts .. "/screenshot.sh region"),            "Screenshot: region")
bind("SHIFT + Print",       exec(scripts .. "/screenshot.sh screen"),            "Screenshot: full screen")
bind(key("Print"),          exec(scripts .. "/screenshot.sh edit"),              "Screenshot: region → editor")
bind(key("SHIFT + C"),      exec(scripts .. "/colorpicker.sh"),                  "Color picker")

-- Media, volume and brightness (with on-screen display, work on the lock screen)
local media = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume",  exec("swayosd-client --output-volume raise"),      "Volume up",        media)
bind("XF86AudioLowerVolume",  exec("swayosd-client --output-volume lower"),      "Volume down",      media)
bind("XF86AudioMute",         exec("swayosd-client --output-volume mute-toggle"), "Mute",            { locked = true })
bind("XF86AudioMicMute",      exec("swayosd-client --input-volume mute-toggle"), "Mute microphone",  { locked = true })
bind("XF86MonBrightnessUp",   exec("swayosd-client --brightness raise"),         "Brightness up",    media)
bind("XF86MonBrightnessDown", exec("swayosd-client --brightness lower"),         "Brightness down",  media)
bind("XF86AudioPlay",         exec("playerctl play-pause"),                      "Play / pause",     { locked = true })
bind("XF86AudioPause",        exec("playerctl play-pause"),                      "Play / pause",     { locked = true })
bind("XF86AudioNext",         exec("playerctl next"),                            "Next track",       { locked = true })
bind("XF86AudioPrev",         exec("playerctl previous"),                        "Previous track",   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Ignore maximize requests from apps; tiling decides.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Don't let the screen sleep while something is fullscreen (videos, games).
hl.window_rule({ name = "idle-inhibit-fullscreen", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Fix XWayland drag-and-drop ghosts.
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Small utility windows float, centered.
hl.window_rule({
    name   = "float-utilities",
    match  = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|nwg-look|qt6ct|hyprland-share-picker|swappy)$" },
    float  = true,
    center = true,
    size   = { "monitor_w*0.45", "monitor_h*0.55" },
})
hl.window_rule({ name = "float-polkit",   match = { class = "^(hyprpolkitagent|polkit.*)$" }, float = true, center = true })
hl.window_rule({ name = "float-dialogs",  match = { title = "^(Open File|Save File|Save As|File Operation Progress|Confirm to replace files)$" }, float = true, center = true })
hl.window_rule({ name = "pip",            match = { title = "^(Picture-in-Picture|Picture in picture)$" }, float = true, pin = true, keep_aspect_ratio = true })

-- No blur on any layer (bar, launcher, notifications stay solid).
hl.layer_rule({ name = "no-anim-selection", match = { namespace = "^(selection|hyprpicker)$" }, no_anim = true })


------------------------
---- USER OVERRIDES ----
------------------------

-- ~/.config/hypr/user.lua (git-ignored) is loaded last so it can override anything above.
-- A missing file is fine; errors inside it show up as normal Hyprland config errors.
pcall(require, "user")
