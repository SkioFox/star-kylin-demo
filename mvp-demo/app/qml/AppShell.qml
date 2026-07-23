import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0
import "components"

Rectangle {
    id: root
    color: Theme.canvas
    property int sidebarWidth: width < 1100 ? 168 : width < 1280 ? 184 : 208
    property bool nativeDialogVisible: false
    property string nativeApplicationName: qsTr("本机工具")
    property string nativeResultTitle: ""
    property string nativeResultMessage: ""
    property string nativeResultDetail: ""
    property string nativeRetryText: ""

    Rectangle {
        id: header
        height: 56
        color: Theme.nav900
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            Rectangle {
                width: 32
                height: 32
                radius: 4
                color: "transparent"
                border.color: "#5A789A"
                IconGlyph { anchors.centerIn: parent; iconName: "landmark"; glyphColor: Theme.goldLight; glyphSize: 19 }
            }
            Text {
                text: qsTr("星麒业务工作台")
                color: Theme.surface
                font.family: Theme.uiFont
                font.pixelSize: 16
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Rectangle {
                width: 92
                height: 30
                radius: 3
                color: "transparent"
                border.color: "#7690AA"
                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    IconGlyph { iconName: "monitor-up"; glyphColor: Theme.goldLight; glyphSize: 14; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: qsTr("演示环境"); color: Theme.surface; font.family: Theme.uiFont; font.pixelSize: 12 }
                }
            }

            Button {
                id: userTrigger
                width: 164
                height: 48
                padding: 0
                onClicked: userMenu.open()
                Accessible.name: qsTr("用户菜单")
                contentItem: Row {
                    spacing: 10
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 16
                        color: Theme.primary100
                        anchors.verticalCenter: parent.verticalCenter
                        Text { anchors.centerIn: parent; text: appController.currentInitial; color: Theme.nav900; font.family: Theme.uiFont; font.pixelSize: 13; font.weight: Font.DemiBold }
                    }
                    Column {
                        width: 92
                        anchors.verticalCenter: parent.verticalCenter
                        Text { width: parent.width; text: appController.currentDisplayName; color: Theme.surface; font.family: Theme.uiFont; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { width: parent.width; text: appController.currentRole; color: "#AFC2D5"; font.family: Theme.uiFont; font.pixelSize: 10; elide: Text.ElideRight }
                    }
                    IconGlyph { iconName: "chevron-down"; glyphColor: "#AFC2D5"; glyphSize: 15; anchors.verticalCenter: parent.verticalCenter }
                }
                background: Rectangle { radius: 4; color: userTrigger.hovered ? Theme.nav800 : "transparent"; border.width: userTrigger.activeFocus ? 2 : 0; border.color: Theme.goldLight }

                Menu {
                    id: userMenu
                    y: parent.height
                    width: 210
                    MenuItem { text: appController.currentUsername + " · " + appController.currentRole; enabled: false }
                    MenuSeparator { }
                    MenuItem { text: qsTr("退出登录"); onTriggered: appController.logout() }
                }
            }
        }
    }

    StatusTrack {
        id: statusTrack
        sidebarWidth: root.sidebarWidth
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
    }

    Sidebar {
        id: sidebar
        width: root.sidebarWidth
        anchors.left: parent.left
        anchors.top: statusTrack.bottom
        anchors.bottom: parent.bottom
    }

    Item {
        id: mainPanel
        anchors.left: sidebar.right
        anchors.right: parent.right
        anchors.top: statusTrack.bottom
        anchors.bottom: parent.bottom

        TaskTabs {
            id: tabs
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: tabs.bottom
            anchors.bottom: parent.bottom

            WorkbenchPage { anchors.fill: parent; visible: appController.activeModuleId === "workbench" }
            WebModulePage { anchors.fill: parent; visible: appController.activeModuleId === "appWeb" }
            KlineModulePage { anchors.fill: parent; visible: appController.activeModuleId === "appKline" }
        }
    }

    NativeDialog {
        z: 100
        visible: root.nativeDialogVisible
        applicationName: root.nativeApplicationName
        resultTitle: root.nativeResultTitle
        resultMessage: root.nativeResultMessage
        resultDetail: root.nativeResultDetail
        retryText: root.nativeRetryText
        onClosed: root.nativeDialogVisible = false
        onRetryRequested: {
            root.nativeDialogVisible = false
            appController.retryNativeModule()
        }
    }

    Toast {
        id: nativeToast
        z: 101
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.top: statusTrack.bottom
        anchors.topMargin: 14
    }

    Connections {
        target: appController
        function onNativeLaunchFailed(name, title, message, detail, retryText) {
            root.nativeApplicationName = name
            root.nativeResultTitle = title
            root.nativeResultMessage = message
            root.nativeResultDetail = detail
            root.nativeRetryText = retryText
            root.nativeDialogVisible = true
        }
        function onNativeLaunchStarted(name, pid) {
            root.nativeDialogVisible = false
            nativeToast.show(name)
        }
    }
}
