// cpu / mem / bat as small plots (magma bar-notes: Right 1-3):
//   cpu ⟋⟍⟋•  23   mem ▂▄▆█▅▃  41   bat ▬▬▬▭  78
// Each label is 10px muted, 6px before its plot; each value is 11px text,
// right-aligned in a 20px slot 4px after the plot. BAT is hidden without a
// battery; below 15% (not charging) its fill and value turn hot.
// Click opens btop.
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Clickable {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery !== null && battery.isLaptopBattery
    readonly property bool charging: hasBattery && (battery.state === UPowerDeviceState.Charging
                                                    || battery.state === UPowerDeviceState.FullyCharged
                                                    || battery.state === UPowerDeviceState.PendingCharge)
    readonly property bool batteryLow: hasBattery && !charging && battery.percentage < 0.15

    onClicked: Quickshell.execDetached(["sh", "-c", "kitty -e btop || kitty -e top"])

    component Label: Text {
        y: 20 - baselineOffset
        font.family: Theme.fontMono
        font.pixelSize: Theme.labelPx
        color: Theme.muted
    }
    component Value: Text {
        property real value: 0
        y: 20 - baselineOffset
        width: Math.max(20, implicitWidth)
        horizontalAlignment: Text.AlignRight
        text: String(Math.round(value * 100)).padStart(2, "0")
        font.family: Theme.fontMono
        font.pixelSize: Theme.valuePx
        color: Theme.fg
    }
    component Gap: Item {
        property int size: 6
        width: size
        height: 1
    }

    Row {
        height: parent.height

        Label { text: "cpu" }
        Gap {}
        Sparkline { values: SysStats.cpuHistory; capacity: SysStats.cpuHistoryLength }
        Gap { size: 4 }
        Value { value: SysStats.cpu }

        Gap { size: 20 }
        Label { text: "mem" }
        Gap {}
        Histogram { values: SysStats.memoryHistory; capacity: SysStats.memoryHistoryLength }
        Gap { size: 4 }
        Value { value: SysStats.memory }

        Gap { size: 22; visible: root.hasBattery }
        Label { text: "bat"; visible: root.hasBattery }
        Gap { visible: root.hasBattery }
        BatteryBar {
            visible: root.hasBattery
            value: root.hasBattery ? root.battery.percentage : 0
            critical: root.batteryLow
        }
        Gap { size: 4; visible: root.hasBattery }
        Value {
            visible: root.hasBattery
            value: root.hasBattery ? root.battery.percentage : 0
            color: root.batteryLow ? Theme.urgent : Theme.fg
        }
    }
}
