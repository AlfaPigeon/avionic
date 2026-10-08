// Clock readout: a 12-tick ring with a sweeping seconds hand, then HH:MM in
// mono and the date as a small engraved label.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Cell {
    id: clock

    ruleLeft: false
    interactive: false
    spacing: 10

    SystemClock {
        id: time
        precision: SystemClock.Seconds
    }

    // Tick ring: 12 ticks around the edge, a dot orbiting once a minute
    Item {
        id: ring

        readonly property real size: 24
        readonly property real centre: size / 2

        implicitWidth: size
        implicitHeight: size

        Repeater {
            model: 12

            Rectangle {
                id: tick

                required property int index
                readonly property bool major: index % 3 === 0

                x: ring.centre - width / 2
                y: 0
                width: 1
                height: major ? 4 : 2
                color: major ? Theme.fgDim : Theme.muted
                antialiasing: true
                transform: Rotation {
                    origin.x: 0.5
                    origin.y: ring.centre
                    angle: tick.index * 30
                }
            }
        }

        // Seconds: a 2px dot on an inner orbit
        Rectangle {
            readonly property real orbit: ring.centre - 7
            readonly property real angle: (time.seconds * 6 - 90) * Math.PI / 180

            x: ring.centre + orbit * Math.cos(angle) - width / 2
            y: ring.centre + orbit * Math.sin(angle) - height / 2
            width: 3
            height: 3
            color: Theme.fg
        }
    }

    MonoText {
        text: Qt.formatDateTime(time.date, "HH:mm")
        font.pointSize: Theme.fontSize + 1
        font.weight: Font.Medium
        font.letterSpacing: 1
    }

    LabelText {
        text: Qt.formatDateTime(time.date, "ddd dd MMM")
    }
}
