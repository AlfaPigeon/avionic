// Battery bar (magma bar-notes: Right 3): 40x6, 1px border outline, fill
// ramp_3 (drawn over the outline, as in the mockup); hot below 15%. Coordinates are bar pixels: the bar sits at y 13.
import QtQuick
import qs

Item {
    id: battery

    property real value: 0      // 0..1
    property bool critical: false

    implicitWidth: 40
    implicitHeight: Theme.barHeight - Theme.border

    Rectangle {
        y: 13
        width: 40
        height: 6
        color: "transparent"
        border.width: Theme.border
        border.color: Theme.overlay
    }

    Rectangle {
        y: 13
        width: 40 * Math.max(0, Math.min(1, battery.value))
        height: 6
        color: battery.critical ? Theme.urgent : Theme.ramp[3]
    }
}
