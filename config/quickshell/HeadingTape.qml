// Workspaces as an aircraft heading tape: a strip of ticks with two-digit
// numbers. The active workspace on this screen is the one amber readout
// (number, caret above, underline below). Occupied workspaces read in text
// color, empty ones muted, urgent ones red.
//
// Switching: HyprlandWorkspace.activate() is Lua-aware in Quickshell >= 0.3
// (it sends hl.dsp.focus({ workspace = "N" }) when Hyprland's configProvider
// is lua). Workspaces that don't exist yet go through goTo(), which builds the
// same Lua dispatch itself.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: tape

    property ShellScreen screen
    readonly property HyprlandMonitor monitor: screen ? Hyprland.monitorFor(screen) : null
    readonly property int activeId: monitor && monitor.activeWorkspace ? monitor.activeWorkspace.id : -1
    readonly property var workspaces: Hyprland.workspaces.values
    readonly property int count: {
        let highest = 10;
        for (const ws of workspaces)
            if (ws.id > highest) highest = ws.id;
        return highest;
    }
    readonly property int cellWidth: 30

    function workspace(id) {
        return workspaces.find(ws => ws.id === id) ?? null;
    }

    // Raw dispatch, in whichever syntax the running Hyprland expects.
    function dispatchFocus(target) {
        if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.focus({ workspace = "${target}" })`);
        else
            Hyprland.dispatch(`workspace ${target}`);
    }

    function goTo(id) {
        const ws = workspace(id);
        if (ws) ws.activate();
        else dispatchFocus(id);
    }

    implicitWidth: count * cellWidth + 16
    implicitHeight: Theme.barHeight

    // Right-hand rule closing the tape
    Rectangle {
        anchors.right: parent.right
        width: Theme.border
        height: parent.height
        color: Theme.overlay
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => tape.dispatchFocus(event.angleDelta.y < 0 ? "e+1" : "e-1")
    }

    Row {
        x: 8
        height: parent.height

        Repeater {
            model: tape.count

            Item {
                id: mark

                required property int index
                readonly property int wsId: index + 1
                readonly property HyprlandWorkspace ws: tape.workspace(wsId)
                readonly property bool active: wsId === tape.activeId
                readonly property bool occupied: ws !== null && ws.toplevels.values.length > 0
                readonly property bool urgent: ws !== null && ws.urgent

                width: tape.cellWidth
                height: parent.height

                Rectangle {
                    anchors.fill: parent
                    color: Theme.surface
                    visible: hover.containsMouse || mark.active
                }

                // Tape graduations: minor ticks at the edge and quarters,
                // a major tick (or the amber caret) at the center.
                Repeater {
                    model: [0, 0.25, 0.75]

                    Rectangle {
                        required property real modelData

                        x: Math.round(mark.width * modelData)
                        y: 0
                        width: 1
                        height: modelData === 0 ? 4 : 2
                        color: Theme.muted
                        opacity: 0.55
                    }
                }
                Rectangle {
                    x: Math.round(parent.width / 2)
                    y: 0
                    width: 1
                    height: 6
                    color: Theme.muted
                    visible: !mark.active
                }
                Caret {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 0
                    visible: mark.active
                    color: Theme.accent
                }

                MonoText {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 2
                    text: String(mark.wsId).padStart(2, "0")
                    font.weight: mark.active ? Font.Bold : Font.Normal
                    color: mark.urgent ? Theme.urgent
                         : mark.active ? Theme.accent
                         : mark.occupied ? Theme.fg
                         : Theme.muted
                }

                // Amber underline on the active workspace, red on an urgent one
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 2
                    color: mark.urgent ? Theme.urgent : Theme.accent
                    visible: mark.active || mark.urgent
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tape.goTo(mark.wsId)
                    onWheel: event => tape.dispatchFocus(event.angleDelta.y < 0 ? "e+1" : "e-1")
                }
            }
        }
    }
}
