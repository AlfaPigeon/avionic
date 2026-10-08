// Battery as an arc gauge, from UPower. Hidden on machines without a laptop battery.
import QtQuick
import Quickshell.Services.UPower

ArcGauge {
    readonly property var device: UPower.displayDevice
    readonly property bool charging: device.state === UPowerDeviceState.Charging
                                     || device.state === UPowerDeviceState.FullyCharged
                                     || device.state === UPowerDeviceState.PendingCharge

    visible: device.isLaptopBattery
    label: charging ? "bat+" : "bat"
    value: device.percentage
    critical: !charging && device.percentage <= 0.12
}
