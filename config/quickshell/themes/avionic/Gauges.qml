// CPU / MEM / BAT gauges. CPU and memory come from /proc (SysStats), the
// battery from UPower; BAT is hidden on machines without a laptop battery.
// Critical: CPU or MEM above 90%, battery below 15% while not charging.
// While charging the battery fill is `success`. Click opens btop.
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

    onClicked: Quickshell.execDetached(["sh", "-c", "kitty -e btop || kitty -e top"])

    Row {
        height: parent.height
        spacing: 9

        ArcGauge {
            label: "cpu"
            value: SysStats.cpu
            critical: SysStats.cpu > 0.9
        }
        ArcGauge {
            label: "mem"
            value: SysStats.memory
            critical: SysStats.memory > 0.9
        }
        ArcGauge {
            visible: root.hasBattery
            label: "bat"
            value: root.hasBattery ? root.battery.percentage : 0
            fill: root.charging ? Theme.success : Theme.fg
            critical: root.hasBattery && !root.charging && root.battery.percentage < 0.15
        }
    }
}
