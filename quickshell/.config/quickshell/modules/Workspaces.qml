import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../components"

Row {
    spacing: 4

    Repeater {
        model: Hyprland.workspaces
        
        CaelestiaItem {
            width: 34
            text: modelData.name
            activeColor: modelData.active ? "#7aa2f7" : "#3d59a1"
            
            // Highlight active workspace even without hover
            Rectangle {
                id: activeHighlight
                anchors.fill: parent
                radius: 8
                color: "#3d59a1"
                opacity: modelData.active ? 0.3 : 0
                visible: !parent.hovered 
            }
            
            onClicked: Hyprland.dispatch(`workspace ${modelData.name}`)
        }
    }
}
