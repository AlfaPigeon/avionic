// Avionic shell · Quickshell (https://quickshell.org), targets Quickshell 0.3.
// One bar per screen. Colors and fonts come from Theme.qml, which
// scripts/apply-theme.sh generates from theme/palette.sh.
//
// Reload from a script:  qs ipc call avionic reload
//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {}
    }

    IpcHandler {
        target: "avionic"

        function reload(): void {
            Quickshell.reload(false);
        }
    }
}
