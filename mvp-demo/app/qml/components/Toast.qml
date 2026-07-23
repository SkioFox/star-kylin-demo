import QtQuick 2.12
import StarKylin 1.0

Item {
    id: root
    property string applicationName: qsTr("本机工具")

    width: 330
    height: 74
    visible: false

    function show(name) {
        applicationName = name
        visible = true
        dismissTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: Theme.surface
        border.color: "#B9C9DA"

        Rectangle {
            width: 4
            radius: 2
            color: Theme.success
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        Rectangle {
            x: 18
            width: 38
            height: 38
            radius: 19
            color: Theme.successSoft
            anchors.verticalCenter: parent.verticalCenter
            IconGlyph { anchors.centerIn: parent; iconName: "badge-check"; glyphColor: Theme.success; glyphSize: 20 }
        }
        Column {
            x: 70
            width: parent.width - 88
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            Text { text: qsTr("应用已启动"); color: Theme.text900; font.family: Theme.uiFont; font.pixelSize: 14; font.weight: Font.DemiBold }
            Text { width: parent.width; text: root.applicationName + qsTr("已在独立进程中启动"); color: Theme.text600; font.family: Theme.uiFont; font.pixelSize: 12; elide: Text.ElideRight }
        }
    }

    Timer { id: dismissTimer; interval: 3600; onTriggered: root.visible = false }
}
