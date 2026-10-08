// Notification state from swaync (swaync-client -swb streams one JSON line per
// change). Click toggles the panel, right click toggles do-not-disturb.
import QtQuick
import Quickshell
import Quickshell.Io

Cell {
    id: notif

    property int count: 0
    property bool dnd: false
    property bool available: false

    visible: available
    spacing: 6

    onClicked: event => Quickshell.execDetached(["swaync-client", event.button === Qt.RightButton ? "-d" : "-t", "-sw"])

    Process {
        id: watch
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const state = JSON.parse(line);
                    notif.count = Number(state.text) || 0;
                    notif.dnd = String(state.alt).startsWith("dnd");
                    notif.available = true;
                } catch (e) {
                    // ignore partial or non-JSON lines
                }
            }
        }
        // swaync may start after the bar, or restart: try again shortly.
        onRunningChanged: {
            if (running) return;
            notif.available = false;
            retry.start();
        }
    }

    Timer {
        id: retry
        interval: 3000
        onTriggered: watch.running = true
    }

    MonoText {
        text: notif.dnd ? "󰂛" : notif.count > 0 ? "󱅫" : "󰂚"
        font.pointSize: Theme.glyphSize
        color: notif.count > 0 && !notif.dnd ? Theme.fg : Theme.muted
    }
    MonoText {
        text: notif.count
        visible: notif.count > 0
    }
}
