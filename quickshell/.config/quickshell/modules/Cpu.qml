import QtQuick
import Quickshell
import Quickshell.Io
import "../components"

CaelestiaItem {
    id: root
    width: 80
    icon: "󰻠 " + cpuUsage + "%"
    property string cpuUsage: "0"

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: cpuProc.running = true
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.cpuUsage = Math.round(parseFloat(this.text)).toString()
                cpuProc.running = false
            }
        }
    }
}
