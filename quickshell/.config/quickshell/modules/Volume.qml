import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

CaelestiaItem {
    id: root
    width: 70
    icon: (muted ? "󰝟 " : "󰕾 ") + volume + "%"
    property string volume: "0"
    property bool muted: false

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }

    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                // Format: Volume: 0.50 [MUTED]
                let match = text.match(/Volume: ([0-9.]+)( \[MUTED\])?/);
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100).toString();
                    root.muted = !!match[2];
                }
                volProc.running = false
            }
        }
    }
    
    onClicked: Hyprland.dispatch("exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
}
