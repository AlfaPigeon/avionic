// Bluetooth from BlueZ (Quickshell.Bluetooth). Click opens blueman.
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Cell {
    id: bt

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter !== null && adapter.enabled
    readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    visible: adapter !== null
    spacing: 6
    onClicked: Quickshell.execDetached(["blueman-manager"])

    MonoText {
        text: !bt.enabled ? "󰂲" : bt.connected > 0 ? "󰂱" : "󰂯"
        font.pointSize: Theme.glyphSize
        color: bt.connected > 0 ? Theme.fg : Theme.muted
    }
    MonoText {
        text: bt.connected
        visible: bt.connected > 0
    }
}
