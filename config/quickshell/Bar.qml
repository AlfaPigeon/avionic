// The Avionic bar, built to Designer's spec (avionic bar-notes.md / bar-mockup):
//   left   mark · heading tape · window title
//   centre date · ruler · HH:MM:SS · ruler · timezone
//   right  CPU/MEM/BAT gauges · NET VOL (BT, MSG when relevant) · tray · power
// 32px tall, bg_alt fill, a 1px overlay rule along the bottom, no rounding,
// no blur. Section dividers are 1px rules inset 7px.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray

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
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.border
        color: Theme.overlay
    }

    // A fixed-width gap
    component Gap: Item {
        property int size: Theme.pad
        width: size
        height: 1
    }

    // ── Left ────────────────────────────────────────────────────────────────
    Row {
        id: left
        height: Theme.barHeight - Theme.border

        Mark {}
        Divider {}
        Gap { size: Theme.pad - 1 }
        HeadingTape {
            screen: bar.screen
        }
        Gap { size: Theme.pad - 1 }
        Divider {}
        Gap { size: Theme.pad - 1 }
        WindowTitle {
            width: Math.max(0, Math.min(implicitWidth, clock.x + clock.contentLeft - left.x - x - 24))
        }
    }

    // ── Centre (true centre of the screen) ─────────────────────────────────
    ClockReadout {
        id: clock

        readonly property real contentLeft: centre - labelGap - 80

        anchors.horizontalCenter: parent.horizontalCenter
        window: bar
    }

    // ── Right ───────────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad
        height: Theme.barHeight - Theme.border

        Gauges {}
        Gap { size: 15 }
        Divider {}
        Gap { size: Theme.pad - 1 }
        NetworkReadout {}
        Gap { size: 22 }
        AudioReadout {}
        Gap { size: 22; visible: bt.visible }
        BluetoothReadout { id: bt }
        Gap { size: 22; visible: msg.visible }
        NotificationsReadout { id: msg }
        Gap {}
        Divider { visible: tray.visible }
        Gap { size: 15; visible: tray.visible }
        Tray {
            id: tray
            window: bar
            visible: SystemTray.items.values.length > 0
        }
        Gap { size: 10; visible: tray.visible }
        Divider {}
        Gap { size: Theme.pad - 1 }
        PowerButton {}
    }
}
