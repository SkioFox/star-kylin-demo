import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Rectangle {
    id: root
    color: Theme.nav950

    Flickable {
        id: navScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: userArea.top
        clip: true
        contentHeight: navColumn.height

        Column {
            id: navColumn
            width: navScroll.width
            spacing: 2

            Text {
                width: parent.width
                height: 38
                leftPadding: 20
                verticalAlignment: Text.AlignVCenter
                text: qsTr("工作区")
                color: "#829DB8"
                font.family: Theme.uiFont
                font.pixelSize: 11
            }
            NavButton {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("工作台")
                iconName: "layout-dashboard"
                active: appController.activeModuleId === "workbench"
                onClicked: appController.activateTab("workbench")
            }
            Text {
                width: parent.width
                height: 40
                leftPadding: 20
                verticalAlignment: Text.AlignVCenter
                text: qsTr("业务办理")
                color: "#829DB8"
                font.family: Theme.uiFont
                font.pixelSize: 11
            }
            Repeater {
                model: appController.moduleModel
                delegate: NavButton {
                    width: navColumn.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: model.type === "web"
                    height: visible ? 44 : 0
                    text: model.name
                    iconName: model.iconName
                    active: appController.activeModuleId === model.id
                    onClicked: appController.openModule(model.id)
                }
            }
            Text {
                visible: appController.moduleModel.count > 1
                width: parent.width
                height: visible ? 40 : 0
                leftPadding: 20
                verticalAlignment: Text.AlignVCenter
                text: qsTr("业务辅助")
                color: "#829DB8"
                font.family: Theme.uiFont
                font.pixelSize: 11
            }
            Repeater {
                model: appController.moduleModel
                delegate: NavButton {
                    width: navColumn.width - 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: model.type !== "web"
                    height: visible ? 44 : 0
                    enabled: model.type !== "native" || !appController.nativeLaunchPending
                    text: model.name
                    iconName: model.iconName
                    active: appController.activeModuleId === model.id
                    onClicked: appController.openModule(model.id)
                }
            }
        }
    }

    Item {
        id: userArea
        height: 118
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        Rectangle {
            height: 1
            color: "#1D456D"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
        }
        Rectangle {
            id: avatar
            x: 16
            y: 16
            width: 32
            height: 32
            radius: 16
            color: "#DCEAFB"
            Text {
                anchors.centerIn: parent
                text: appController.currentInitial
                color: Theme.nav900
                font.family: Theme.uiFont
                font.pixelSize: 13
                font.weight: Font.DemiBold
            }
        }
        Text {
            anchors.left: avatar.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: avatar.top
            text: appController.currentDisplayName
            color: Theme.surface
            font.family: Theme.uiFont
            font.pixelSize: 13
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        Text {
            anchors.left: avatar.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.top: avatar.top
            anchors.topMargin: 19
            text: appController.currentRole
            color: "#91A9C0"
            font.family: Theme.uiFont
            font.pixelSize: 11
            elide: Text.ElideRight
        }
        NavButton {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            text: qsTr("退出登录")
            iconName: "log-out"
            onClicked: appController.logout()
        }
    }
}
