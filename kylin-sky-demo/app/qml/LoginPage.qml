import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import KylinSky 1.0

Item {
    id: root
    property bool submitting: appController.loginPending
    property string validationError: ""

    function submit() {
        validationError = ""
        if (!username.text.length || !password.text.length) {
            validationError = qsTr("请输入用户名和密码后继续。")
            return
        }
        appController.login(username.text, password.text)
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Rectangle {
            id: identityPanel
            width: Math.max(430, parent.width * 0.42)
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: Theme.command

            Rectangle {
                width: 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.line
            }

            Column {
                width: Math.min(390, identityPanel.width - 96)
                anchors.left: parent.left
                anchors.leftMargin: 64
                anchors.verticalCenter: parent.verticalCenter
                spacing: 13

                Row {
                    spacing: 10
                    Rectangle { width: 42; height: 42; color: "#C88A24"; radius: 6
                        Image { anchors.centerIn: parent; width: 24; height: 24; source: "qrc:/icons/landmark.svg"; fillMode: Image.PreserveAspectFit }
                    }
                }
                Rectangle { width: 48; height: 3; color: Theme.signal }
                Text { text: qsTr("统一业务与市场观察入口"); color: Theme.label; font.pixelSize: Math.round(12 * Theme.textScale); font.family: Theme.dataFont }
                Text { text: qsTr("麒麟工作台"); color: "#FFFFFF"; font.pixelSize: Math.round(31 * Theme.textScale); font.bold: true }
                Text {
                    width: parent.width
                    text: qsTr("在同一工作区处理获授权应用、市场研究与本机工具；当前会话状态始终可见。")
                    color: "#C6D9E8"
                    font.pixelSize: Math.round(14 * Theme.textScale)
                    wrapMode: Text.Wrap
                    lineHeight: 1.45
                }
                Rectangle { width: parent.width; height: 1; color: "#234963" }
                Repeater {
                    model: [qsTr("统一会话与权限加载"), qsTr("受控业务系统接入"), qsTr("原生行情与工具协同")]
                    delegate: Row {
                        spacing: 8
                        Rectangle { width: 6; height: 6; radius: 3; color: Theme.signal; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: modelData; color: "#DCE8F2"; font.pixelSize: Math.round(12 * Theme.textScale) }
                    }
                }
                Item { width: 1; height: 28 }
                Text { text: qsTr("内部演示环境 / V2.1"); color: "#91ACC2"; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont }
            }
        }

        Rectangle {
            width: 500
            height: form.implicitHeight + 64
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: identityPanel.right
            anchors.leftMargin: Math.max(54, (parent.width - identityPanel.width - width) / 2)
            color: Theme.loginSurface
            border.width: 0

            Column {
                id: form
                width: parent.width - 72
                anchors.centerIn: parent
                spacing: 10

                Text { text: qsTr("工作账号登录"); color: Theme.loginAction; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                Text { text: qsTr("进入工作台"); color: Theme.loginInk; font.pixelSize: Math.round(26 * Theme.textScale); font.bold: true }
                Text { text: qsTr("请使用已分配的演示工作账号。登录后将加载当前账号获授权的应用入口。 "); color: Theme.loginMuted; font.pixelSize: Math.round(12 * Theme.textScale); wrapMode: Text.Wrap; width: parent.width }
                Item { width: 1; height: 3 }

                Text { text: qsTr("用户名"); color: Theme.loginInk; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                TextField {
                    id: username
                    width: parent.width; height: 44
                    enabled: !root.submitting
                    placeholderText: qsTr("输入用户名")
                    selectByMouse: true
                    KeyNavigation.tab: password
                    color: Theme.loginInk
                    font.pixelSize: Math.round(13 * Theme.textScale)
                    placeholderTextColor: "#99AABB"
                    background: Rectangle { color: Theme.loginSurface; border.width: 1; border.color: username.activeFocus ? Theme.loginAction : Theme.loginLine }
                }
                Text { text: qsTr("密码"); color: Theme.loginInk; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                TextField {
                    id: password
                    width: parent.width; height: 44
                    enabled: !root.submitting
                    echoMode: TextInput.Password
                    placeholderText: qsTr("输入密码")
                    selectByMouse: true
                    color: Theme.loginInk
                    font.pixelSize: Math.round(13 * Theme.textScale)
                    placeholderTextColor: "#99AABB"
                    onAccepted: root.submit()
                    background: Rectangle { color: Theme.loginSurface; border.width: 1; border.color: password.activeFocus ? Theme.loginAction : Theme.loginLine }
                }
                Text {
                    width: parent.width
                    height: text.length ? implicitHeight : 0
                    visible: text.length > 0
                    text: root.validationError.length ? root.validationError : appController.loginError
                    color: Theme.up
                    font.pixelSize: Math.round(12 * Theme.textScale)
                    wrapMode: Text.Wrap
                }
                Button {
                    id: loginButton
                    width: parent.width; height: 44
                    enabled: !root.submitting
                    text: root.submitting ? qsTr("正在验证") : qsTr("登录工作台")
                    onClicked: root.submit()
                    contentItem: Text { text: loginButton.text; color: "#FFFFFF"; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: loginButton.down ? "#075B9D" : loginButton.hovered ? "#075B9D" : Theme.loginAction; border.width: 1; border.color: loginButton.activeFocus ? Theme.signal : Theme.loginAction }
                }
                Rectangle { width: parent.width; height: 1; color: "#E6EDF4" }
                Text { text: qsTr("演示账号：operator / KylinDemo2026"); color: Theme.loginMuted; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont }
            }
        }
    }
}
