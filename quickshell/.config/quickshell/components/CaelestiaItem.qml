import QtQuick

// Polished Caelestia-style capsule item
Item {
    id: root
    property alias text: label.text
    property alias icon: label.text
    property color activeColor: "#7aa2f7"
    property bool active: false
    
    implicitWidth: label.implicitWidth + 24
    implicitHeight: 30

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 12
        color: root.active ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.2) : 
               (hoverArea.containsMouse ? "rgba(255, 255, 255, 0.1)" : "transparent")
        
        border.width: root.active ? 1 : 0
        border.color: root.activeColor

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    Text {
        id: label
        anchors.centerIn: parent
        color: root.active ? "white" : (hoverArea.containsMouse ? "white" : "#a9b1d6")
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        font.weight: root.active ? Font.Bold : Font.Normal

        Behavior on color { ColorAnimation { duration: 200 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    signal clicked()

    // Smooth indicator dot
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.active ? 4 : 0
        height: 4
        radius: 2
        color: root.activeColor
        
        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1.00]
            }
        }
    }
}
