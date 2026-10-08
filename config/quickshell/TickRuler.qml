pragma ComponentBehavior: Bound

// Ruler beside the clock: 8 ticks, 6px apart, every 4th one taller (8px vs 4px).
// `direction` is +1 to grow rightwards from x=0, -1 to grow leftwards.
import QtQuick

Item {
    id: ruler

    property int direction: 1
    property int count: 8
    property int step: 6

    implicitWidth: (count - 1) * step + 1
    implicitHeight: 8

    Repeater {
        model: ruler.count

        Rectangle {
            required property int index
            readonly property bool tall: (index + 1) % 4 === 0
            readonly property int offset: index * ruler.step

            x: ruler.direction > 0 ? offset : ruler.width - 1 - offset
            y: tall ? 0 : 2
            width: 1
            height: tall ? 8 : 4
            color: Theme.overlay
        }
    }
}
