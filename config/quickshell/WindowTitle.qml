// Title of the focused window, quiet and elided.
import QtQuick
import Quickshell.Hyprland

Item {
    id: title

    readonly property string text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""

    implicitWidth: label.implicitWidth + Theme.cellPadding * 2
    implicitHeight: Theme.barHeight
    clip: true

    MonoText {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.cellPadding
        anchors.rightMargin: Theme.cellPadding
        anchors.verticalCenter: parent.verticalCenter
        text: title.text
        color: Theme.muted
        elide: Text.ElideRight
    }
}
