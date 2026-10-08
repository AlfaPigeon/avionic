// Hyprland workspace helpers shared by every bar layout: lookup, window
// counts and switching. Switching speaks whichever dispatcher syntax the
// running Hyprland expects (Lua config on 0.55+, hyprlang before that).
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    readonly property var all: Hyprland.workspaces.values

    function find(id) {
        return all.find(ws => ws.id === id) ?? null;
    }

    // Windows on a workspace (0 when it doesn't exist).
    function windowCount(id) {
        const ws = find(id);
        if (!ws) return 0;
        const live = ws.toplevels ? ws.toplevels.values.length : 0;
        const ipc = ws.lastIpcObject && ws.lastIpcObject.windows !== undefined ? ws.lastIpcObject.windows : 0;
        return Math.max(live, ipc);
    }

    // Workspace ids to show: always 1..9, plus any existing ones above 9.
    function ids() {
        const list = [1, 2, 3, 4, 5, 6, 7, 8, 9];
        for (const ws of all)
            if (ws.id > 9) list.push(ws.id);
        return list.sort((a, b) => a - b);
    }

    // Raw dispatch: "5", "e+1", "e-1" …
    function focus(target) {
        if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.focus({ workspace = "${target}" })`);
        else
            Hyprland.dispatch(`workspace ${target}`);
    }

    function goTo(id) {
        const ws = find(id);
        if (ws) ws.activate();   // Lua-aware since Quickshell 0.3
        else focus(id);
    }
}
