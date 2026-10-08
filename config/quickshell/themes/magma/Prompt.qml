// Prompt mark (magma bar-notes: Left 1): a bold rose λ, then "magma" in muted.
import QtQuick
import qs

Item {
    implicitWidth: 78
    implicitHeight: Theme.barHeight - Theme.border

    Text {
        x: 12
        y: 21 - baselineOffset
        text: "λ"
        font.family: Theme.fontMono
        font.pixelSize: 14
        font.weight: Font.Bold
        color: Theme.accent
    }

    Text {
        x: 28
        y: 20 - baselineOffset
        text: "magma"
        font.family: Theme.fontMono
        font.pixelSize: Theme.valuePx
        color: Theme.muted
    }
}
