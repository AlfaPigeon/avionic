// Wraps a readout: on hover it fills `surface` behind the content (full bar
// height, a few px wider than the content) and forwards clicks and scrolls.
import QtQuick

Item {
    id: root

    default property alias content: holder.data
    property int hoverMargin: 6
    property bool hoverFill: true
    readonly property bool hovered: mouse.containsMouse

    signal clicked(var mouse)
    signal scrolled(var wheel)

    implicitWidth: holder.childrenRect.width
    implicitHeight: Theme.barHeight - Theme.border

    Rectangle {
        x: -root.hoverMargin
        y: 0
        width: root.width + root.hoverMargin * 2
        height: root.height
        color: Theme.surface
        opacity: root.hoverFill && mouse.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.hoverMs } }
    }

    Item {
        id: holder
        anchors.fill: parent
    }

    MouseArea {
        id: mouse
        x: -root.hoverMargin
        width: root.width + root.hoverMargin * 2
        height: root.height
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: event => root.clicked(event)
        onWheel: event => root.scrolled(event)
    }
}
