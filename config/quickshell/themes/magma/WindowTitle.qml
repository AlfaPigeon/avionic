// Focused window (magma bar-notes: Left 3): the app class in the accent,
// a space (9px, as drawn in the mockup), then the title in text_dim, cut to about 60 characters in all and
// elided to the space available.
import QtQuick
import Quickshell.Hyprland
import qs

Item {
    id: root

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property string appClass: {
        if (!toplevel) return "";
        const ipc = toplevel.lastIpcObject;
        if (ipc && ipc.class) return ipc.class;
        return toplevel.wayland ? toplevel.wayland.appId : "";
    }
    readonly property string title: {
        if (!toplevel || !toplevel.title) return "";
        const room = 60 - (appClass.length ? appClass.length + 1 : 0);
        const t = toplevel.title;
        return t.length > room ? t.slice(0, Math.max(0, room - 1)) + "…" : t;
    }

    readonly property real gap: appClass.length ? 9 : 0

    implicitWidth: cls.implicitWidth + (title.length ? gap + full.advanceWidth : 0)
    implicitHeight: Theme.barHeight - Theme.border
    clip: true

    Text {
        id: cls
        y: 20 - baselineOffset
        text: root.appClass
        font.family: Theme.fontUi
        font.pixelSize: Theme.valuePx
        color: Theme.accent
    }

    TextMetrics {
        id: full
        font: label.font
        text: root.title
    }

    Text {
        id: label
        x: cls.implicitWidth + root.gap
        y: 20 - baselineOffset
        width: Math.max(0, root.width - x)
        text: root.title
        font.family: Theme.fontUi
        font.pixelSize: Theme.valuePx
        color: Theme.fgDim
        elide: Text.ElideRight
    }
}
