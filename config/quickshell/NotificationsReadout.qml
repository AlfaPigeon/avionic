// MSG <n> / MSG dnd from swaync (swaync-client -swb streams one JSON line per
// change). Only shown when there is something to report, so the resting bar
// matches the mockup. Click toggles the panel, right click do-not-disturb.
import QtQuick
import Quickshell
import Quickshell.Io

Clickable {
    id: notif

    property int count: 0
    property bool dnd: false

    visible: count > 0 || dnd
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
                } catch (e) {
                    // ignore partial or non-JSON lines
                }
            }
        }
        // swaync may start after the bar, or restart: try again shortly.
        onRunningChanged: {
            if (running) return;
            notif.count = 0;
            notif.dnd = false;
            retry.start();
        }
    }

    Timer {
        id: retry
        interval: 3000
        onTriggered: watch.running = true
    }

    Row {
        height: parent.height
        spacing: 8

        LabelText {
            anchors.verticalCenter: parent.verticalCenter
            text: "msg"
        }
        ValueText {
            anchors.verticalCenter: parent.verticalCenter
            text: notif.dnd ? "dnd" : notif.count
            color: notif.dnd ? Theme.muted : Theme.fg
        }
    }
}
