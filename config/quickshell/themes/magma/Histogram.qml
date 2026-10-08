// Memory histogram (magma bar-notes: Right 2): the last 8 readings as 4px bars
// with 1px gaps, up to 16px tall, ramp_2; a bar above 90% uses ramp_4.
// Newest on the right. Coordinates are bar pixels: bars stand on y 24.
pragma ComponentBehavior: Bound

import QtQuick
import qs

Item {
    id: hist

    property list<real> values: []
    property int capacity: 8

    implicitWidth: capacity * 5
    implicitHeight: Theme.barHeight - Theme.border

    Repeater {
        model: hist.values.length

        Rectangle {
            required property int index
            readonly property real value: Math.max(0, Math.min(1, hist.values[index]))

            x: (hist.capacity - hist.values.length + index) * 5
            width: 4
            height: Math.max(1, Math.round(value * 16))
            y: 24 - height
            color: value > 0.9 ? Theme.ramp[4] : Theme.ramp[2]
        }
    }
}
