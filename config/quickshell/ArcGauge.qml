// A thin 270° arc gauge with the value inside and a label beside it.
// Track in the rule color, value in text color, red only when critical.
// Amber is deliberately not used here.
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

RowLayout {
    id: gauge

    property string label: ""
    property real value: 0          // 0..1
    property bool critical: false
    property string valueText: Math.round(Math.max(0, Math.min(1, value)) * 100)
    readonly property color valueColor: critical ? Theme.urgent : Theme.fg

    spacing: 5

    Item {
        id: dial

        readonly property real size: 24
        readonly property real stroke: 1.5
        readonly property real r: (size - stroke) / 2

        implicitWidth: size
        implicitHeight: size

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            // Track
            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.overlay
                strokeWidth: dial.stroke
                capStyle: ShapePath.FlatCap
                PathAngleArc {
                    centerX: dial.size / 2
                    centerY: dial.size / 2
                    radiusX: dial.r
                    radiusY: dial.r
                    startAngle: 135
                    sweepAngle: 270
                }
            }

            // Value
            ShapePath {
                fillColor: "transparent"
                strokeColor: gauge.valueColor
                strokeWidth: dial.stroke
                capStyle: ShapePath.FlatCap
                PathAngleArc {
                    centerX: dial.size / 2
                    centerY: dial.size / 2
                    radiusX: dial.r
                    radiusY: dial.r
                    startAngle: 135
                    sweepAngle: 270 * Math.max(0, Math.min(1, gauge.value))
                }
            }
        }

        MonoText {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 1
            text: gauge.valueText
            font.pointSize: Theme.labelSize
            color: gauge.valueColor
        }
    }

    LabelText {
        text: gauge.label
        visible: text.length > 0
    }
}
