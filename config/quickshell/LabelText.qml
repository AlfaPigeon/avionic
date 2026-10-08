// Small caps label: IBM Plex Sans, muted, letter-spaced like panel engraving.
import QtQuick

Text {
    font.family: Theme.fontUi
    font.pointSize: Theme.labelSize
    font.weight: Font.Medium
    font.letterSpacing: 1
    font.capitalization: Font.AllUppercase
    color: Theme.muted
    verticalAlignment: Text.AlignVCenter
}
