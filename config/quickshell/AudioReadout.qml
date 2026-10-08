// Default output volume via PipeWire. Scroll to change, right-click to mute,
// click for pavucontrol.
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Cell {
    id: audio

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property bool muted: ready && sink.audio.muted
    readonly property real volume: ready ? sink.audio.volume : 0

    visible: ready
    spacing: 6

    // Properties of a node are only live while something tracks it.
    PwObjectTracker {
        objects: [audio.sink]
    }

    onClicked: event => {
        if (event.button === Qt.RightButton) sink.audio.muted = !sink.audio.muted;
        else Quickshell.execDetached(["pavucontrol"]);
    }
    onScrolled: event => {
        const step = event.angleDelta.y > 0 ? 0.05 : -0.05;
        sink.audio.volume = Math.max(0, Math.min(1.5, sink.audio.volume + step));
    }

    MonoText {
        text: audio.muted ? "󰖁" : audio.volume < 0.34 ? "󰕿" : audio.volume < 0.67 ? "󰖀" : "󰕾"
        font.pointSize: Theme.glyphSize
        color: Theme.muted
    }
    MonoText {
        text: audio.muted ? "MUTE" : Math.round(audio.volume * 100)
        color: audio.muted ? Theme.muted : Theme.fg
    }
    LabelText {
        text: "vol"
    }
}
