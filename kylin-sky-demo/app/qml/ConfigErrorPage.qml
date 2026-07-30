import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Rectangle {
    color: Theme.canvas
    Column {
        width: Math.min(520, parent.width - 64)
        anchors.centerIn: parent
        spacing: 14
        Rectangle { width: 42; height: 3; color: Theme.up }
        Label { text: qsTr("应用配置不可用"); color: Theme.ink; font.pixelSize: Math.round(24 * Theme.textScale); font.bold: true }
        Label { width: parent.width; text: qsTr("只读模块清单未通过启动校验，应用未加载任何业务入口。"); wrapMode: Text.Wrap; color: Theme.muted; lineHeight: 1.4 }
        Label { width: parent.width; text: appController.configurationError; wrapMode: Text.Wrap; color: Theme.up; lineHeight: 1.4 }
    }
}
