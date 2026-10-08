// Section divider: a 1px vertical rule, inset 7px from the top and bottom.
import QtQuick

Item {
    implicitWidth: Theme.border
    implicitHeight: Theme.barHeight

    Rectangle {
        y: Theme.dividerInset
        width: parent.width
        height: Theme.barHeight - Theme.dividerInset * 2
        color: Theme.overlay
    }
}
