// The Avionic bar: a flat instrument strip along the top edge of one screen.
//   left   heading tape (workspaces) · focused window title
//   center clock readout
//   right  CPU / MEM / BAT gauges · audio · network · bluetooth · tray · notifications · power
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar

    required property ShellScreen modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.bgAlt

    WlrLayershell.namespace: "avionic-bar"
    WlrLayershell.layer: WlrLayer.Top

    // Bottom rule
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.border
        color: Theme.overlay
        z: 1
    }

    RowLayout {
        id: left
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 0

        HeadingTape {
            Layout.fillHeight: true
            screen: bar.screen
        }

        WindowTitle {
            Layout.fillHeight: true
            Layout.maximumWidth: Math.max(0, clock.x - left.x - 160)
        }
    }

    ClockReadout {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    RowLayout {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 0

        Tray {
            Layout.fillHeight: true
            window: bar
        }

        Cell {
            Layout.fillHeight: true
            onClicked: Quickshell.execDetached(["sh", "-c", "kitty -e btop || kitty -e top"])

            ArcGauge {
                label: "cpu"
                value: SysStats.cpu
                critical: SysStats.cpu >= 0.9
            }
            ArcGauge {
                label: "mem"
                value: SysStats.memory
                critical: SysStats.memory >= 0.9
            }
            BatteryGauge {}
        }

        AudioReadout {
            Layout.fillHeight: true
        }

        NetworkReadout {
            Layout.fillHeight: true
        }

        BluetoothReadout {
            Layout.fillHeight: true
        }

        NotificationsReadout {
            Layout.fillHeight: true
        }

        PowerButton {
            Layout.fillHeight: true
        }
    }
}
