// Arc gauge (bar-notes: Right 1): 16px ring, 270° sweep from bottom-left,
// 2px stroke, track in `overlay`, fill in `fg` (or a given color). Then the
// label (10px muted) and a two-digit value (11px fg). Red when critical.
// Columns as in the mockup: label 22px and value 52px from the ring's left edge.
import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: gauge

    property string label: ""
    property real value: 0                 // 0..1
    property bool critical: false
    property color fill: Theme.fg
    readonly property real clamped: Math.max(0, Math.min(1, value))
    readonly property color shown: critical ? Theme.urgent : fill

    implicitWidth: 52 + reading.implicitWidth
    implicitHeight: Theme.barHeight - Theme.border

    Shape {
        id: ring

        readonly property real size: 16
        readonly property real stroke: 2

        anchors.verticalCenter: parent.verticalCenter
        width: size
        height: size
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.overlay
            strokeWidth: ring.stroke
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                centerX: ring.size / 2
                centerY: ring.size / 2
                radiusX: ring.size / 2
                radiusY: ring.size / 2
                startAngle: 135
                sweepAngle: 270
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: gauge.shown
            strokeWidth: ring.stroke
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                centerX: ring.size / 2
                centerY: ring.size / 2
                radiusX: ring.size / 2
                radiusY: ring.size / 2
                startAngle: 135
                sweepAngle: 270 * gauge.clamped
            }
        }
    }

    LabelText {
        x: 22
        anchors.verticalCenter: parent.verticalCenter
        text: gauge.label
    }

    ValueText {
        id: reading
        x: 52
        anchors.verticalCenter: parent.verticalCenter
        text: String(Math.round(gauge.clamped * 100)).padStart(2, "0")
        color: gauge.critical ? Theme.urgent : Theme.fg
    }
}
