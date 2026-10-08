// Focused window as "class  ·  title" in IBM Plex Sans 11px, fg_dim,
// shortened to about 60 characters and elided to the space available.
import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    readonly property var toplevel: Hyprland.activeToplevel
    readonly property string appClass: {
        if (!toplevel) return "";
        const ipc = toplevel.lastIpcObject;
        if (ipc && ipc.class) return ipc.class;
        return toplevel.wayland ? toplevel.wayland.appId : "";
    }
    readonly property string text: {
        if (!toplevel) return "";
        const full = [appClass, toplevel.title].filter(s => s && s.length > 0).join("  ·  ");
        return full.length > 60 ? full.slice(0, 59) + "…" : full;
    }

    implicitWidth: label.implicitWidth
    implicitHeight: Theme.barHeight - Theme.border
    clip: true

    Text {
        id: label
        width: root.width
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        font.family: Theme.fontUi
        font.pixelSize: Theme.valuePx
        color: Theme.fgDim
        elide: Text.ElideRight
    }
}
