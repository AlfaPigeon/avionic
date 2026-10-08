// VOL <percent> for the default output (PipeWire); "mute" in muted.
// Scroll changes volume, click opens the mixer, right click toggles mute.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Clickable {
    id: audio

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property bool muted: ready && sink.audio.muted

    // A node's properties are only live while something tracks it.
    PwObjectTracker {
        objects: [audio.sink]
    }

    onClicked: event => {
        if (event.button === Qt.RightButton) {
            if (ready) sink.audio.muted = !sink.audio.muted;
        } else {
            Quickshell.execDetached(["pavucontrol"]);
        }
    }
    onScrolled: event => {
        if (!ready) return;
        const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + step));
    }

    Row {
        height: parent.height
        spacing: 8

        LabelText {
            anchors.verticalCenter: parent.verticalCenter
            text: "vol"
        }
        ValueText {
            anchors.verticalCenter: parent.verticalCenter
            text: !audio.ready ? "--" : audio.muted ? "mute" : Math.round(audio.sink.audio.volume * 100)
            color: audio.ready && !audio.muted ? Theme.fg : Theme.muted
        }
    }
}
