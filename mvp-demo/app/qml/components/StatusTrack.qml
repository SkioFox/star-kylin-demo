import QtQuick 2.12
import StarKylin 1.0

Rectangle {
    id: root
    property int sidebarWidth: 208
    height: 32
    color: "#F7FAFD"
    border.color: Theme.border
    clip: true

    Rectangle {
        id: labelArea
        width: root.sidebarWidth
        height: parent.height
        color: Theme.nav800
        Rectangle {
            width: 3
            color: Theme.gold
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            Rectangle {
                width: 7
                height: 7
                radius: 4
                color: "#66D7A4"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: qsTr("业务状态")
                color: Theme.surface
                font.family: Theme.uiFont
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }
        }
    }

    Row {
        anchors.left: labelArea.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Repeater {
            model: [
                { icon: "monitor-up", label: "环境：", value: "演示环境", width: 138 },
                { icon: "server", label: "本地 Mock：", value: "可用", width: 150 },
                { icon: "database", label: "本地数据：", value: "09:30:00", width: 170 },
                { icon: "user-round", label: "角色：", value: appController.currentRole, width: 170 }
            ]
            delegate: Item {
                width: modelData.width
                height: root.height
                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    IconGlyph {
                        iconName: modelData.icon
                        glyphColor: Theme.primary600
                        glyphSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: modelData.label + modelData.value
                        color: Theme.text700
                        font.family: modelData.icon === "database" ? Theme.dataFont : Theme.uiFont
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Rectangle {
                    width: 1
                    color: Theme.border
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                }
            }
        }
    }
}
