// Wordmark: a 14x2 amber dash, then AVIONIC letter-spaced in muted.
import QtQuick

Item {
    implicitWidth: 102
    implicitHeight: Theme.barHeight - Theme.border

    Rectangle {
        x: 12
        y: 15
        width: 14
        height: 2
        color: Theme.accent
    }

    LabelText {
        x: 34
        anchors.verticalCenter: parent.verticalCenter
        text: "avionic"
        font.letterSpacing: 2
    }
}
