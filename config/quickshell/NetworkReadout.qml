// NET <interface> from NetworkManager (Quickshell.Networking); "off" in muted
// when nothing is connected. The readout is right-aligned in a fixed slot
// (as in the mockups) so the gauges don't shift as names change.
// Click opens nm-connection-editor.
import QtQuick
import Quickshell
import Quickshell.Networking

Clickable {
    id: net

    property int slot: 87

    readonly property var devices: Networking.devices.values
    readonly property var device: {
        const up = devices.filter(d => d.connected);
        return up.find(d => d.type === DeviceType.Wifi) ?? up[0] ?? null;
    }

    onClicked: Quickshell.execDetached(["nm-connection-editor"])

    Item {
        implicitWidth: Math.max(net.slot, row.implicitWidth)
        implicitHeight: parent.height

        Row {
            id: row
            anchors.right: parent.right
            height: parent.height
            spacing: 8

            LabelText {
                anchors.verticalCenter: parent.verticalCenter
                text: "net"
            }
            ValueText {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, 120)
                elide: Text.ElideRight
                text: net.device ? net.device.name : "off"
                color: net.device ? Theme.fg : Theme.muted
            }
        }
    }
}
