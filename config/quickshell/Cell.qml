// A square bar cell: 1px rule on the left, hover fill, and click/scroll signals.
// Children are laid out in a row and vertically centered.
import QtQuick
import QtQuick.Layouts

Item {
    id: cell

    default property alias content: row.data
    property bool ruleLeft: true
    property bool interactive: true
    property int padding: Theme.cellPadding
    property alias spacing: row.spacing
    readonly property bool hovered: mouse.containsMouse

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.barHeight

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        visible: cell.interactive && mouse.containsMouse
    }

    Rectangle {
        width: Theme.border
        height: parent.height
        color: Theme.overlay
        visible: cell.ruleLeft
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: cell.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => cell.clicked(event)
        onWheel: event => cell.scrolled(event)
    }
}
