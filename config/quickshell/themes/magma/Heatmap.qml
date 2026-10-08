// Workspace heatmap (magma bar-notes: Left 2). Nine 22x20 cells, 4px apart,
// filled by window count on the magma ramp (empty = outline only), plus a cell
// for any workspace above 9 that exists. Active: a 1.5px text-colored outline
// 2px outside the cell and a bolder digit. Urgent: filled hot, whatever the
// count. Followed by an "n_win" legend. Click switches, scroll cycles.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs

Item {
    id: map

    property ShellScreen screen
    readonly property HyprlandMonitor monitor: screen ? Hyprland.monitorFor(screen) : null
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
    readonly property var ids: {
        Workspaces.all;   // re-evaluate when workspaces come and go
        return Workspaces.ids();
    }

    implicitWidth: cells.width + 8 + legend.implicitWidth
    implicitHeight: Theme.barHeight - Theme.border

    Row {
        id: cells
        y: 6
        spacing: 4

        Repeater {
            model: map.ids

            Item {
                id: cell

                required property int modelData
                readonly property var ws: { Workspaces.all; return Workspaces.find(modelData); }
                readonly property int count: { Workspaces.all; return Workspaces.windowCount(modelData); }
                readonly property bool active: modelData === map.activeId
                readonly property bool urgent: ws !== null && ws.urgent
                readonly property bool empty: count === 0 && !urgent
                readonly property color fill: urgent ? Theme.urgent
                                            : empty ? (area.containsMouse ? Theme.surface : Theme.bgAlt)
                                            : Theme.ramp[Math.min(count, 4)]

                width: 22
                height: 20

                // Hover on a filled cell: a surface ring in the 2px margin.
                Rectangle {
                    x: -2
                    y: -2
                    width: parent.width + 4
                    height: parent.height + 4
                    color: Theme.surface
                    visible: area.containsMouse && !cell.empty
                }

                Rectangle {
                    anchors.fill: parent
                    color: cell.fill
                    border.width: cell.empty ? Theme.border : 0
                    border.color: Theme.overlay
                    Behavior on color { ColorAnimation { duration: Theme.hoverMs } }
                }

                // Active outline: 1.5px, centred 2px outside the cell (as drawn in the mockup).
                Rectangle {
                    visible: cell.active
                    x: -2.75
                    y: -2.75
                    width: parent.width + 5.5
                    height: parent.height + 5.5
                    color: "transparent"
                    border.width: 1.5
                    border.color: Theme.fg
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 14 - baselineOffset
                    text: cell.modelData
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.valuePx
                    font.weight: cell.active ? Font.DemiBold : Font.Normal
                    color: cell.urgent ? Theme.bg
                         : cell.empty ? Theme.muted
                         : cell.count <= 2 ? Theme.fg
                         : Theme.bg
                }

                MouseArea {
                    id: area
                    x: -2
                    y: -6
                    width: parent.width + 4
                    height: Theme.barHeight - Theme.border
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Workspaces.goTo(cell.modelData)
                    onWheel: event => Workspaces.focus(event.angleDelta.y < 0 ? "e+1" : "e-1")
                }
            }
        }
    }

    Text {
        id: legend
        x: cells.width + 8
        y: 20 - baselineOffset
        text: "n_win"
        font.family: Theme.fontMono
        font.pixelSize: Theme.labelPx
        color: Theme.muted
    }
}
