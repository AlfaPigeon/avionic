// Month calendar under the clock: square, surface fill, 1px rule border.
// Scroll or use the arrows to change month; clicking outside closes it.
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

PopupWindow {
    id: popup

    required property Item anchorItem
    required property var window
    property date today: new Date()
    property int year: today.getFullYear()
    property int month: today.getMonth()
    property real closedAt: 0

    readonly property int cellW: 30
    readonly property int cellH: 22
    readonly property int firstDay: Qt.locale().firstDayOfWeek % 7   // 0 = Sunday

    function toggle() {
        // A click on the clock while open first closes the popup via the grab;
        // don't immediately reopen it.
        if (visible || Date.now() - closedAt < 250) {
            visible = false;
            return;
        }
        year = today.getFullYear();
        month = today.getMonth();
        visible = true;
    }

    function shift(delta) {
        const d = new Date(year, month + delta, 1);
        year = d.getFullYear();
        month = d.getMonth();
    }

    // 42 cells (6 weeks) starting on the locale's first day of the week
    readonly property var days: {
        const first = new Date(year, month, 1);
        const lead = (first.getDay() - firstDay + 7) % 7;
        const list = [];
        for (let i = 0; i < 42; i++)
            list.push(new Date(year, month, 1 - lead + i));
        return list;
    }

    anchor.item: anchorItem
    anchor.rect.x: anchorItem.width / 2
    anchor.rect.y: anchorItem.height + Theme.border
    anchor.edges: Edges.Top
    anchor.gravity: Edges.Bottom
    grabFocus: true
    visible: false
    onVisibleChanged: if (!visible) closedAt = Date.now()

    implicitWidth: cellW * 7 + 24
    implicitHeight: content.implicitHeight + 24
    color: Theme.surface

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: Theme.border
        border.color: Theme.overlay
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => popup.shift(event.angleDelta.y > 0 ? -1 : 1)
    }

    Column {
        id: content
        x: 12
        y: 12
        spacing: 6

        // Header: ‹  OCT 2026  ›
        Item {
            width: popup.cellW * 7
            height: 18

            LabelText {
                anchors.centerIn: parent
                text: Qt.formatDate(new Date(popup.year, popup.month, 1), "MMM yyyy")
                font.letterSpacing: 1.5
                color: Theme.fg
            }
            Repeater {
                model: [-1, 1]

                LabelText {
                    required property int modelData

                    x: modelData < 0 ? 0 : parent.width - width
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData < 0 ? "‹" : "›"
                    font.pixelSize: Theme.clockPx
                    color: arrow.containsMouse ? Theme.fg : Theme.muted

                    MouseArea {
                        id: arrow
                        anchors.fill: parent
                        anchors.margins: -6
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.shift(parent.modelData)
                    }
                }
            }
        }

        // Weekday initials
        Row {
            Repeater {
                model: 7

                LabelText {
                    required property int index

                    width: popup.cellW
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.locale().dayName((popup.firstDay + index) % 7, Locale.ShortFormat).slice(0, 2)
                }
            }
        }

        Grid {
            columns: 7

            Repeater {
                model: popup.days

                Item {
                    id: day

                    required property date modelData
                    readonly property bool inMonth: modelData.getMonth() === popup.month
                    readonly property bool isToday: modelData.toDateString() === popup.today.toDateString()

                    width: popup.cellW
                    height: popup.cellH

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        color: "transparent"
                        border.width: day.isToday ? Theme.border : 0
                        border.color: Theme.fgDim
                    }

                    ValueText {
                        anchors.centerIn: parent
                        text: day.modelData.getDate()
                        color: day.isToday ? Theme.fg : day.inMonth ? Theme.fgDim : Theme.overlay
                    }
                }
            }
        }
    }
}
