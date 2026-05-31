import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

CaelestiaItem {
    id: root
    icon: connected ? "󰖩" : "󰖪"
    property bool connected: false

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    Process {
        id: netProc
        command: ["sh", "-c", "iwctl station wlan0 show | grep 'State' | grep -v 'disconnected'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.connected = this.text.trim().length > 0;
                netProc.running = false
            }
        }
    }
}
