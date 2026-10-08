// BT <n>: only shown while Bluetooth devices are connected (not part of the
// mockup's resting state). Click opens blueman.
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Clickable {
    id: bt

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connected: adapter ? adapter.devices.values.filter(d => d.connected).length : 0

    visible: connected > 0
    onClicked: Quickshell.execDetached(["blueman-manager"])

    Row {
        height: parent.height
        spacing: 8

        LabelText {
            anchors.verticalCenter: parent.verticalCenter
            text: "bt"
        }
        ValueText {
            anchors.verticalCenter: parent.verticalCenter
            text: bt.connected
        }
    }
}
