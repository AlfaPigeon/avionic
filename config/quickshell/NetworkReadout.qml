// Network state from NetworkManager (Quickshell.Networking).
// Wi-Fi shows the SSID, wired shows ETH, offline shows a muted glyph.
import QtQuick
import Quickshell
import Quickshell.Networking

Cell {
    id: net

    readonly property var devices: Networking.devices.values
    readonly property var device: {
        const up = devices.filter(d => d.connected);
        return up.find(d => d.type === DeviceType.Wifi) ?? up[0] ?? null;
    }
    readonly property bool wifi: device !== null && device.type === DeviceType.Wifi
    readonly property var network: wifi ? (device.networks.values.find(n => n.connected) ?? null) : null
    readonly property string ssid: network ? network.name : ""

    spacing: 6
    onClicked: Quickshell.execDetached(["nm-connection-editor"])

    MonoText {
        text: net.device === null ? "󰖪" : net.wifi ? "󰖩" : "󰈀"
        font.pointSize: Theme.glyphSize
        color: net.device === null ? Theme.muted : Theme.fgDim
    }
    MonoText {
        text: net.device === null ? "OFFLINE"
            : net.wifi ? (net.ssid.length > 14 ? net.ssid.slice(0, 13) + "…" : net.ssid || "WIFI")
            : "ETH"
        color: net.device === null ? Theme.muted : Theme.fg
    }
    LabelText {
        text: "net"
    }
}
