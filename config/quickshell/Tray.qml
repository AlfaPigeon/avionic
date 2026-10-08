// System tray: 14px icons, 20px apart, tinted monochrome (muted, fg on hover).
// Left click activates, right click opens the app's menu, middle click is
// the secondary action.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Row {
    id: tray

    required property QsWindow window

    height: Theme.barHeight - Theme.border
    spacing: 6

    Repeater {
        model: SystemTray.items

        Item {
            id: entry

            required property SystemTrayItem modelData

            width: 14
            height: tray.height

            Rectangle {
                x: -3
                width: parent.width + 6
                height: parent.height
                color: Theme.surface
                opacity: area.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Theme.hoverMs } }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 14
                source: entry.modelData.icon
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1
                    colorizationColor: area.containsMouse ? Theme.fg : Theme.muted
                }
            }

            MouseArea {
                id: area
                x: -3
                width: parent.width + 6
                height: parent.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: event => {
                    const item = entry.modelData;
                    if (event.button === Qt.MiddleButton) {
                        item.secondaryActivate();
                    } else if (event.button === Qt.RightButton || item.onlyMenu) {
                        if (item.hasMenu) {
                            const pos = entry.mapToItem(tray.window.contentItem, 0, 0);
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
