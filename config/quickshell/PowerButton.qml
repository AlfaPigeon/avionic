// Power button (bar-notes: Right 4): 20x20 square, 1px `overlay` border, a
// drawn power glyph in muted that turns fg on hover. Opens the power menu.
import QtQuick
import QtQuick.Shapes
import Quickshell

Item {
    id: power

    implicitWidth: 20
    implicitHeight: Theme.barHeight - Theme.border

    Rectangle {
        id: box
        anchors.verticalCenter: parent.verticalCenter
        width: 20
        height: 20
        color: area.containsMouse ? Theme.surface : "transparent"
        border.width: Theme.border
        border.color: Theme.overlay
        Behavior on color { ColorAnimation { duration: Theme.hoverMs } }

        // Power glyph: an open ring and a stem (as drawn in the mockup)
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: area.containsMouse ? Theme.fg : Theme.muted
                strokeWidth: 1.5
                capStyle: ShapePath.FlatCap
                PathAngleArc {
                    centerX: 10
                    centerY: 9.9
                    radiusX: 5
                    radiusY: 5
                    startAngle: -33
                    sweepAngle: 246
                }
            }
            ShapePath {
                fillColor: "transparent"
                strokeColor: area.containsMouse ? Theme.fg : Theme.muted
                strokeWidth: 1.5
                capStyle: ShapePath.FlatCap
                startX: 10
                startY: 3
                PathLine { x: 10; y: 9 }
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: box
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/powermenu.sh"])
    }
}
