// Centre readout (bar-notes: Center), on the true centre of the screen:
//   THU 08 OCT  ·ruler·  HH:MM:SS  ·ruler·  UTC+3
// HH:MM 14px fg weight 500, :SS muted. Rulers start 52px from the centre
// (as drawn in the mockup). Click opens a month calendar.
import QtQuick
import Quickshell

Item {
    id: clock

    required property var window   // the bar, for the calendar popup

    readonly property real centre: width / 2
    readonly property int rulerStart: 52
    readonly property int labelGap: 112   // date / timezone edge from the centre
    readonly property string zone: {
        const offset = -time.date.getTimezoneOffset();   // minutes east of UTC
        if (offset === 0) return "UTC";
        const sign = offset > 0 ? "+" : "-";
        const h = Math.floor(Math.abs(offset) / 60), m = Math.abs(offset) % 60;
        return "UTC" + sign + h + (m ? ":" + String(m).padStart(2, "0") : "");
    }

    implicitWidth: (labelGap + Math.max(date.implicitWidth, tz.implicitWidth)) * 2 + 24
    implicitHeight: Theme.barHeight - Theme.border

    SystemClock {
        id: time
        precision: SystemClock.Seconds
    }

    Clickable {
        x: date.x
        width: tz.x + tz.width - date.x
        height: parent.height
        hoverMargin: 10
        onClicked: calendar.toggle()
    }

    LabelText {
        id: date
        x: clock.centre - clock.labelGap - width + font.letterSpacing   // Qt pads the last glyph too
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(time.date, "ddd dd MMM")
        font.letterSpacing: 1.5
    }

    TickRuler {
        direction: -1
        x: clock.centre - clock.rulerStart - width + 1
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: Qt.formatDateTime(time.date, "HH:mm")
            font.family: Theme.fontMono
            font.pixelSize: Theme.clockPx
            font.weight: Font.Medium
            color: Theme.fg
        }
        Text {
            text: Qt.formatDateTime(time.date, ":ss")
            font.family: Theme.fontMono
            font.pixelSize: Theme.clockPx
            font.weight: Font.Medium
            color: Theme.muted
        }
    }

    TickRuler {
        direction: 1
        x: clock.centre + clock.rulerStart
        anchors.verticalCenter: parent.verticalCenter
    }

    LabelText {
        id: tz
        x: clock.centre + clock.labelGap
        anchors.verticalCenter: parent.verticalCenter
        text: clock.zone
        font.letterSpacing: 1.5
    }

    CalendarPopup {
        id: calendar
        anchorItem: clock
        window: clock.window
        today: time.date
    }
}
