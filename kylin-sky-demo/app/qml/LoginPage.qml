import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    property bool submitting: appController.loginPending
    property string validationError: ""

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        Rectangle {
            width: parent.width * 0.42
            anchors.top: parent.top; anchors.bottom: parent.bottom
            color: Theme.nav
            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left; anchors.leftMargin: 64
                width: parent.width - 112; spacing: 14
                Rectangle { width: 42; height: 3; color: Theme.gold }
                Label { text: qsTr("统一业务与市场观察入口"); color: "#B8CADB" }
                Label { text: qsTr("麒麟工作台"); color: "white"; font.pixelSize: 32; font.bold: true }
                Label { width: parent.width; wrapMode: Text.Wrap; lineHeight: 1.4; text: qsTr("在同一工作区处理授权应用、市场研究和本机工具，当前会话状态始终可见。"); color: "#C8D8E7" }
                Label { text: qsTr("会话与权限统一管理\n受控业务系统接入\n原生行情与工具协同"); color: "#DCE8F2"; lineHeight: 1.55 }
            }
        }
        Column {
            width: 420; anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: parent.width * 0.54; spacing: 10
            Label { text: qsTr("工作账号登录"); color: Theme.primary; font.bold: true }
            Label { text: qsTr("进入工作台"); color: Theme.ink; font.pixelSize: 26; font.bold: true }
            Label { text: qsTr("请使用已分配的工作账号。"); color: Theme.muted }
            Label { text: qsTr("用户名"); color: Theme.ink; topPadding: 12 }
            TextField { id: username; width: parent.width; enabled: !submitting; placeholderText: qsTr("输入用户名"); KeyNavigation.tab: password }
            Label { text: qsTr("密码"); color: Theme.ink }
            TextField { id: password; width: parent.width; enabled: !submitting; echoMode: TextInput.Password; placeholderText: qsTr("输入密码"); onAccepted: submit() }
            Label {
                width: parent.width
                color: Theme.up
                text: validationError.length > 0 ? validationError : appController.loginError
                visible: text.length > 0
                wrapMode: Text.Wrap
            }
            Button {
                width: parent.width; enabled: !submitting
                text: submitting ? qsTr("正在验证") : qsTr("登录工作台")
                onClicked: submit()
            }
            Label { text: qsTr("演示账号：operator / KylinDemo2026"); color: Theme.muted; font.pixelSize: 12 }
        }
    }

    function submit() {
        validationError = ""
        if (!username.text.length || !password.text.length) {
            validationError = qsTr("请输入用户名和密码后继续。")
            return
        }
        appController.login(username.text, password.text)
    }
}
