// Centre readout (magma bar-notes: Center), on the true centre of the screen:
//   t = HH:MM:SS  2026-10-08
// "t =" 11px muted, HH:MM 14px text weight 500, :SS muted, the ISO date 11px
// muted. Positions are measured from the centre as drawn in the mockup.
// Click opens a month calendar.
import QtQuick
import Quickshell
import qs

Item {
    id: clock

    required property var window   // the bar, for the calendar popup

    readonly property real centre: width / 2
    readonly property real contentLeft: label.x   // for the window title's room

    implicitWidth: 2 * (36 + date.implicitWidth + 4)
    implicitHeight: Theme.barHeight - Theme.border

    SystemClock {
        id: time
        precision: SystemClock.Seconds
    }

    Clickable {
        x: label.x
        width: date.x + date.width - label.x
        height: parent.height
        hoverMargin: 10
        onClicked: calendar.toggle()
    }

    Text {
        id: label
        x: clock.centre - 60 - width
        y: 20 - baselineOffset
        text: "t ="
        font.family: Theme.fontMono
        font.pixelSize: Theme.valuePx
        color: Theme.muted
    }

    Text {
        id: hhmm
        x: clock.centre - 52
        y: 21 - baselineOffset
        text: Qt.formatDateTime(time.date, "HH:mm")
        font.family: Theme.fontMono
        font.pixelSize: Theme.clockPx
        font.weight: Font.Medium
        color: Theme.fg
    }

    Text {
        x: hhmm.x + hhmm.implicitWidth
        y: 21 - baselineOffset
        text: Qt.formatDateTime(time.date, ":ss")
        font.family: Theme.fontMono
        font.pixelSize: Theme.clockPx
        font.weight: Font.Medium
        color: Theme.muted
    }

    Text {
        id: date
        x: clock.centre + 36
        y: 20 - baselineOffset
        text: Qt.formatDateTime(time.date, "yyyy-MM-dd")
        font.family: Theme.fontMono
        font.pixelSize: Theme.valuePx
        color: Theme.muted
    }

    CalendarPopup {
        id: calendar
        anchorItem: clock
        window: clock.window
        today: time.date
    }
}
