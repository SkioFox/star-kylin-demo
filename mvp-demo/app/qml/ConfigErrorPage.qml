import QtQuick 2.12
import StarKylin 1.0
import "components"

Rectangle {
    color: Theme.canvas

    Rectangle {
        id: header
        height: 56
        color: Theme.nav900
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        Rectangle { height: 3; color: Theme.gold; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom }
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            IconGlyph { iconName: "landmark"; glyphColor: Theme.goldLight; glyphSize: 18; anchors.verticalCenter: parent.verticalCenter }
            Text { text: qsTr("星麒业务工作台"); color: Theme.surface; font.family: Theme.uiFont; font.pixelSize: 15; font.weight: Font.DemiBold }
        }
    }

    Rectangle {
        width: Math.min(520, parent.width - 40)
        height: 314
        radius: 6
        color: Theme.surface
        border.color: Theme.border
        anchors.centerIn: parent

        Rectangle {
            id: iconCircle
            width: 56
            height: 56
            radius: 28
            color: Theme.dangerSoft
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 28
            IconGlyph { anchors.centerIn: parent; iconName: "triangle-alert"; glyphColor: Theme.danger; glyphSize: 25 }
        }
        Text {
            anchors.top: iconCircle.bottom
            anchors.topMargin: 18
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("演示配置无效")
            color: Theme.text900
            font.family: Theme.uiFont
            font.pixelSize: 22
            font.weight: Font.DemiBold
        }
        Text {
            y: 142
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("工作台无法启动。请检查只读 Manifest 后重新运行应用。")
            color: Theme.text600
            font.family: Theme.uiFont
            font.pixelSize: 14
        }
        Rectangle {
            x: 28
            y: 184
            width: parent.width - 56
            height: 38
            color: "#F5F8FB"
            Rectangle { width: 3; color: Theme.danger; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom }
            Text {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                verticalAlignment: Text.AlignVCenter
                text: qsTr("配置检查未通过 · ") + appController.configurationError
                color: Theme.text700
                font.family: Theme.dataFont
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
        StyledButton {
            y: 242
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("退出演示")
            secondary: true
            onClicked: appController.quit()
        }
    }
}
