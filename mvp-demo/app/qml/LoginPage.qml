import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0
import "components"

Rectangle {
    id: root
    color: Theme.surface

    function submit() {
        if (!appController.loginPending) appController.login(username.text, password.text)
    }

    Rectangle {
        id: identity
        width: Math.max(300, Math.round(root.width * 0.36))
        height: parent.height
        color: Theme.nav900
        Rectangle { width: 4; color: Theme.gold; anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right }

        Row {
            id: brand
            x: Math.max(32, Math.min(54, identity.width * 0.11))
            y: Math.max(28, Math.min(38, identity.height * 0.05))
            spacing: 12
            Rectangle {
                width: 42
                height: 42
                radius: 4
                color: "transparent"
                border.color: "#5A789A"
                IconGlyph { anchors.centerIn: parent; iconName: "landmark"; glyphColor: Theme.goldLight; glyphSize: 23 }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                Text { text: qsTr("XX银行"); color: Theme.surface; font.family: Theme.uiFont; font.pixelSize: 17; font.weight: Font.DemiBold }
                Text { text: "KYLIN DESKTOP · DEMO"; color: "#91A9C0"; font.family: Theme.dataFont; font.pixelSize: 9 }
            }
        }

        Item {
            id: identityCopy
            x: brand.x
            y: Math.max(116, Math.min(166, identity.height * 0.22))
            width: identity.width - x - 28
            height: 92
            Rectangle { width: 38; height: 3; color: Theme.gold }
            Text {
                y: 31
                width: parent.width
                text: qsTr("星麒业务工作台")
                color: Theme.surface
                font.family: Theme.uiFont
                font.pixelSize: root.height < 600 ? 27 : 32
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                y: 77
                width: parent.width
                text: qsTr("面向内部业务人员的统一桌面入口")
                color: "#AFC2D5"
                font.family: Theme.uiFont
                font.pixelSize: 14
                elide: Text.ElideRight
            }
        }

        Column {
            id: trustList
            x: brand.x
            y: identityCopy.y + identityCopy.height + (root.height < 600 ? 22 : 35)
            spacing: root.height < 600 ? 10 : 16
            Repeater {
                model: [
                    { icon: "shield-check", text: "授权入口 · 按角色呈现" },
                    { icon: "database", text: "本地数据 · 不连接真实行情" },
                    { icon: "lock-keyhole", text: "受控访问 · 演示环境" }
                ]
                delegate: Row {
                    spacing: 12
                    IconGlyph { iconName: modelData.icon; glyphColor: Theme.goldLight; glyphSize: 18; anchors.verticalCenter: parent.verticalCenter }
                    Text { text: modelData.text; color: "#D0DCE8"; font.family: Theme.uiFont; font.pixelSize: 13 }
                }
            }
        }

        Rectangle {
            x: brand.x
            width: identity.width - x - 58
            height: 1
            color: "#34577C"
            anchors.bottom: identityFoot.top
            anchors.bottomMargin: 24
        }
        Item {
            id: identityFoot
            x: brand.x
            width: identity.width - x - 58
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 32
            Text { anchors.left: parent.left; text: qsTr("麒麟桌面端"); color: "#839BB4"; font.family: Theme.uiFont; font.pixelSize: 11 }
            Text { anchors.right: parent.right; text: "MVP v0.1"; color: "#839BB4"; font.family: Theme.dataFont; font.pixelSize: 10 }
        }
    }

    Item {
        id: formArea
        anchors.left: identity.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Column {
            id: form
            width: Math.min(420, formArea.width - 64)
            anchors.centerIn: parent
            spacing: 0

            Row {
                spacing: 8
                Rectangle { width: 24; height: 2; color: Theme.gold; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("演示环境"); color: Theme.primary600; font.family: Theme.uiFont; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Text {
                topPadding: 25
                text: qsTr("Mock 演示登录")
                color: Theme.text900
                font.family: Theme.uiFont
                font.pixelSize: 26
                font.weight: Font.DemiBold
            }
            Text {
                topPadding: 8
                bottomPadding: 28
                text: qsTr("登录后进入当前角色的授权工作台。")
                color: Theme.text600
                font.family: Theme.uiFont
                font.pixelSize: 14
            }

            Text { text: qsTr("用户名"); color: Theme.text700; font.family: Theme.uiFont; font.pixelSize: 13; font.weight: Font.DemiBold }
            TextField {
                id: username
                width: parent.width
                height: 46
                topPadding: 0
                bottomPadding: 0
                leftPadding: 13
                rightPadding: 13
                text: "demoA"
                selectByMouse: true
                enabled: !appController.loginPending
                font.family: Theme.uiFont
                font.pixelSize: 14
                color: Theme.text900
                Accessible.name: qsTr("用户名")
                Keys.onReturnPressed: root.submit()
                background: Rectangle {
                    radius: 4
                    color: Theme.surface
                    border.width: username.activeFocus ? 2 : 1
                    border.color: appController.loginError.length > 0 ? Theme.danger
                                                                           : username.activeFocus ? Theme.primary600 : Theme.borderStrong
                }
            }

            Text { topPadding: 20; text: qsTr("密码"); color: Theme.text700; font.family: Theme.uiFont; font.pixelSize: 13; font.weight: Font.DemiBold }
            Item {
                width: parent.width
                height: 46
                TextField {
                    id: password
                    anchors.fill: parent
                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 13
                    rightPadding: 50
                    text: "demo-only"
                    echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                    selectByMouse: true
                    enabled: !appController.loginPending
                    font.family: Theme.uiFont
                    font.pixelSize: 14
                    color: Theme.text900
                    Accessible.name: qsTr("密码")
                    Keys.onReturnPressed: root.submit()
                    background: Rectangle {
                        radius: 4
                        color: Theme.surface
                        border.width: password.activeFocus ? 2 : 1
                        border.color: appController.loginError.length > 0 ? Theme.danger
                                                                               : password.activeFocus ? Theme.primary600 : Theme.borderStrong
                    }
                }
                IconButton {
                    id: showPassword
                    checkable: true
                    anchors.right: parent.right
                    anchors.rightMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    iconName: checked ? "eye-off" : "eye"
                    toolTip: checked ? qsTr("隐藏密码") : qsTr("显示密码")
                }
            }

            Rectangle {
                width: parent.width
                height: 42
                color: appController.loginError.length > 0 ? Theme.dangerSoft : "transparent"
                Rectangle { visible: appController.loginError.length > 0; width: 3; color: Theme.danger; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom }
                Row {
                    visible: appController.loginError.length > 0
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    IconGlyph { iconName: "triangle-alert"; glyphColor: Theme.danger; glyphSize: 16; anchors.verticalCenter: parent.verticalCenter }
                    Text { width: parent.width - 24; text: appController.loginError; color: "#912F3A"; font.family: Theme.uiFont; font.pixelSize: 13; wrapMode: Text.Wrap }
                }
            }

            StyledButton {
                width: parent.width
                text: appController.loginPending ? qsTr("正在登录") : qsTr("登录")
                enabled: !appController.loginPending
                onClicked: root.submit()
            }
            Item { width: 1; height: 16 }
            Row {
                spacing: 8
                anchors.horizontalCenter: parent.horizontalCenter
                IconGlyph { iconName: "badge-check"; glyphColor: Theme.text600; glyphSize: 16; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("当前页面仅使用演示账号和 Mock 数据"); color: Theme.text600; font.family: Theme.uiFont; font.pixelSize: 12 }
            }
        }
    }

    Connections {
        target: appController
        function onLoginErrorChanged() {
            if (appController.loginError.length > 0) password.forceActiveFocus()
        }
    }

    Component.onCompleted: username.forceActiveFocus()
}
