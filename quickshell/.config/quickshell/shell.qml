import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "modules"
import "components"

PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 44
    color: "transparent" // Floating segments look

    // Segments Container
    Row {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 0
        height: 34
        spacing: 12

        // Left Segment: Launcher & Workspaces
        Rectangle {
            height: parent.height
            width: leftRow.width + 20
            radius: 16
            color: "#16161e" // Tokyo Night Night
            border.color: "#24283b"
            border.width: 1

            Row {
                id: leftRow
                anchors.centerIn: parent
                spacing: 4
                
                CaelestiaItem {
                    icon: "󰣇"
                    width: 34
                    activeColor: "#1793d1"
                    onClicked: Hyprland.dispatch("exec walker")
                }

                Workspaces {}
            }
        }

        // Center Segment: Clock
        Rectangle {
            height: parent.height
            width: clockItem.width + 20
            radius: 16
            color: "#16161e"
            border.color: "#24283b"
            border.width: 1

            CaelestiaItem {
                id: clockItem
                anchors.centerIn: parent
                width: 80
                
                Text {
                    id: clockText
                    anchors.centerIn: parent
                    color: "white"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
                    }
                }
            }
        }

        // Right Segment: System
        Rectangle {
            height: parent.height
            width: rightRow.width + 20
            radius: 16
            color: "#16161e"
            border.color: "#24283b"
            border.width: 1

            Row {
                id: rightRow
                anchors.centerIn: parent
                spacing: 4

                Cpu {}
                Network {}
                Volume {}
            }
        }
    }
}
