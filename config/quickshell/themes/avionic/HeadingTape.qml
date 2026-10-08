// Workspaces as an aircraft heading tape (bar-notes: Left 2).
// Always 01-09, 34px per cell; workspaces above 9 that exist get extra cells.
//   empty: muted · occupied: fg · urgent: urgent red
//   active (this screen): surface fill, 2px amber line on top, amber number
//   at weight 600 and an 8x5 amber caret pointing up from the bottom edge.
// Ticks along the bottom: 5px at each cell boundary, 2px at each centre.
//
// Switching: HyprlandWorkspace.activate() is Lua-aware in Quickshell >= 0.3
// (it sends hl.dsp.focus({ workspace = "N" }) when Hyprland's configProvider
// is lua). Workspaces that don't exist yet, and scrolling, go through
// dispatchFocus(), which builds the same dispatch itself.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Hyprland
import qs

Item {
    id: tape

    property ShellScreen screen
    readonly property HyprlandMonitor monitor: screen ? Hyprland.monitorFor(screen) : null
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property var ids: {
        workspaces;   // re-evaluate when workspaces come and go
        return Workspaces.ids();
    }
    readonly property int cell: Theme.tapeCell
    readonly property int tickBottom: Theme.barHeight - Theme.border

    function workspace(id) {
        return Workspaces.find(id);
    }

    function dispatchFocus(target) {
        Workspaces.focus(target);
    }

    function goTo(id) {
        Workspaces.goTo(id);
    }

    implicitWidth: ids.length * cell + 1
    implicitHeight: tickBottom

    Repeater {
        model: tape.ids

        Item {
            id: mark

            required property int modelData
            required property int index
            readonly property HyprlandWorkspace ws: tape.workspace(modelData)
            readonly property bool active: modelData === tape.activeId
            readonly property bool occupied: ws !== null && ws.toplevels.values.length > 0
            readonly property bool urgent: ws !== null && ws.urgent

            x: index * tape.cell
            width: tape.cell
            height: tape.tickBottom

            // Hover / active fill (1px inset so the boundary ticks stay visible)
            Rectangle {
                x: 1
                width: parent.width - 2
                height: parent.height
                color: Theme.surface
                opacity: mark.active || hover.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.hoverMs } }
            }

            // Amber line on the top edge
            Rectangle {
                x: 1
                width: parent.width - 2
                height: 2
                color: Theme.accent
                visible: mark.active
            }

            Text {
                anchors.centerIn: parent
                text: String(mark.modelData).padStart(2, "0")
                font.family: Theme.fontMono
                font.pixelSize: Theme.valuePx
                font.weight: mark.active ? Font.DemiBold : Font.Normal
                color: mark.active ? Theme.accent
                     : mark.urgent ? Theme.urgent
                     : mark.occupied ? Theme.fg
                     : Theme.muted
            }

            // Boundary tick (left edge) and centre tick
            Rectangle {
                x: 0
                y: tape.tickBottom - 5
                width: 1
                height: 5
                color: Theme.overlay
            }
            Rectangle {
                x: Math.floor(parent.width / 2)
                y: tape.tickBottom - 2
                width: 1
                height: 2
                color: Theme.overlay
                visible: !mark.active
            }

            // Amber caret pointing up from the bottom edge
            Shape {
                x: Math.floor(parent.width / 2) - 4
                y: tape.tickBottom - 5
                width: 8
                height: 5
                visible: mark.active
                preferredRendererType: Shape.CurveRenderer

                ShapePath {
                    strokeWidth: 0
                    strokeColor: "transparent"
                    fillColor: Theme.accent
                    startX: 0
                    startY: 5
                    PathLine { x: 4; y: 0 }
                    PathLine { x: 8; y: 5 }
                    PathLine { x: 0; y: 5 }
                }
            }

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: tape.goTo(mark.modelData)
                onWheel: event => tape.dispatchFocus(event.angleDelta.y < 0 ? "e+1" : "e-1")
            }
        }
    }

    // Closing boundary tick
    Rectangle {
        x: tape.ids.length * tape.cell
        y: tape.tickBottom - 5
        width: 1
        height: 5
        color: Theme.overlay
    }
}
