// The Magma bar, built to Designer's spec (magma/bar-notes.md / bar-mockup):
//   left   λ magma · workspace heatmap + n_win · class title
//   centre t = HH:MM:SS  ISO date
//   right  cpu sparkline · mem histogram · bat bar · net vol (bt, msg when
//          relevant) · tray · power
// Same frame as Avionic: 32px tall, bg_alt fill, a 1px border rule along the
// bottom, 1px dividers inset 7px. Every number is drawn as a small plot.
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs

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

    WlrLayershell.namespace: "avionic-bar"   // same namespace for every theme (layer rules)
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

        Prompt {}
        Divider {}
        Gap { size: Theme.pad - 1 }
        Heatmap {
            screen: bar.screen
        }
        Gap { size: 20 }
        Divider {}
        Gap { size: Theme.pad - 1 }
        WindowTitle {
            width: Math.max(0, Math.min(implicitWidth, clock.x + clock.contentLeft - left.x - x - 24))
        }
    }

    // ── Centre (true centre of the screen) ─────────────────────────────────
    ClockReadout {
        id: clock

        anchors.horizontalCenter: parent.horizontalCenter
        window: bar
    }

    // ── Right ───────────────────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.pad
        height: Theme.barHeight - Theme.border

        Stats {}
        Gap {}
        Divider {}
        Gap { size: Theme.pad - 1 }
        NetworkReadout { slot: 84 }
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
