// Label, 10px muted. Avionic: uppercase and letter-spaced (CPU, NET).
// Magma: lowercase like variable names (cpu, net).
import QtQuick

Text {
    readonly property bool upper: Theme.bar === "avionic"

    font.family: Theme.fontMono
    font.pixelSize: Theme.labelPx
    font.letterSpacing: upper ? 1 : 0
    font.capitalization: upper ? Font.AllUppercase : Font.MixedCase
    color: Theme.muted
    verticalAlignment: Text.AlignVCenter
}
