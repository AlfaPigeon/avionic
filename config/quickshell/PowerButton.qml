// Power menu (scripts/powermenu.sh: wlogout if installed, otherwise rofi).
import Quickshell

Cell {
    id: power

    padding: 14
    onClicked: Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/powermenu.sh"])

    MonoText {
        text: "󰐥"
        font.pointSize: Theme.glyphSize
        color: power.hovered ? Theme.urgent : Theme.muted
    }
}
