// CPU sparkline (magma bar-notes: Right 1): the last 30 samples (one per
// second) as a 72x16 line, 1.5px accent stroke over a 1px border baseline,
// with a hot dot on the newest sample. Coordinates are bar pixels: the plot
// spans y 8..24.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs

Item {
    id: spark

    property list<real> values: []
    property int capacity: 30
    readonly property real plotWidth: 72
    readonly property real plotTop: 8
    readonly property real plotBottom: 24
    readonly property real step: plotWidth / (capacity - 1)
    readonly property var points: {
        const n = values.length;
        const out = [];
        for (let i = 0; i < n; i++) {
            const v = Math.max(0, Math.min(1, values[i]));
            out.push(Qt.point(plotWidth - (n - 1 - i) * step, plotBottom - v * (plotBottom - plotTop)));
        }
        return out;
    }

    implicitWidth: plotWidth
    implicitHeight: Theme.barHeight - Theme.border

    // Baseline
    Rectangle {
        y: spark.plotBottom
        width: spark.plotWidth
        height: 1
        color: Theme.overlay
    }

    Shape {
        anchors.fill: parent
        visible: spark.points.length > 1
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.accent
            strokeWidth: 1.5
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathPolyline {
                path: spark.points
            }
        }
    }

    // Newest sample
    Rectangle {
        readonly property point last: spark.points.length ? spark.points[spark.points.length - 1] : Qt.point(0, 0)
        visible: spark.points.length > 0
        x: last.x - 2
        y: last.y - 2
        width: 4
        height: 4
        radius: 2
        color: Theme.urgent
    }
}
