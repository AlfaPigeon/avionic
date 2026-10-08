// System tray (StatusNotifierItem). Left click activates, right click opens the
// app's menu. Hidden when empty.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Cell {
    id: tray

    required property QsWindow window

    visible: SystemTray.items.values.length > 0
    interactive: false
    spacing: 10

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.fill: parent
                source: entry.modelData.icon
                opacity: area.containsMouse ? 1 : 0.8
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    const item = entry.modelData;
                    if (event.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (event.button === Qt.RightButton || item.onlyMenu) {
                        if (item.hasMenu) {
                            const pos = entry.mapToItem(tray.window.contentItem, 0, entry.height);
                            item.display(tray.window, pos.x, Theme.barHeight);
                        }
                    } else {
                        item.activate();
                    }
                }
                onWheel: event => entry.modelData.scroll(event.angleDelta.y, false)
            }
        }
    }
}
