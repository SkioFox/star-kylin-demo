import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

FocusScope {
    id: root
    property string applicationName: qsTr("本机工具")
    property string resultTitle: qsTr("未找到指定应用")
    property string resultMessage: qsTr("请确认验收机已安装清单中的固定应用，然后重新检测。")
    property string resultDetail: qsTr("检测目标：清单中的固定应用路径")
    property string retryText: qsTr("重新检测")
    signal closed()
    signal retryRequested()

    anchors.fill: parent
    focus: visible
    Keys.onEscapePressed: root.closed()

    Rectangle {
        anchors.fill: parent
        color: "#7A061E38"
    }

    Rectangle {
        width: Math.min(460, root.width - 48)
        height: 292
        radius: 6
        color: Theme.surface
        border.color: "#C8D4E1"
        anchors.centerIn: parent

        Item {
            id: heading
            height: 54
            anchors.left: parent.left
            anchors.right: parent.right
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                text: root.applicationName
                color: Theme.text900
                font.family: Theme.uiFont
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            IconButton {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                iconName: "x"
                toolTip: qsTr("关闭")
                onClicked: root.closed()
            }
            Rectangle { height: 1; color: Theme.border; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom }
        }

        Rectangle {
            id: warningIcon
            x: 22
            y: 79
            width: 48
            height: 48
            radius: 24
            color: Theme.warningSoft
            IconGlyph { anchors.centerIn: parent; iconName: "triangle-alert"; glyphColor: Theme.warning; glyphSize: 23 }
        }
        Text {
            anchors.left: warningIcon.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 22
            anchors.top: warningIcon.top
            text: root.resultTitle
            color: Theme.text900
            font.family: Theme.uiFont
            font.pixelSize: 17
            font.weight: Font.DemiBold
        }
        Text {
            anchors.left: warningIcon.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 22
            anchors.top: warningIcon.top
            anchors.topMargin: 34
            text: root.resultMessage
            color: Theme.text600
            font.family: Theme.uiFont
            font.pixelSize: 13
            lineHeight: 1.5
            wrapMode: Text.Wrap
        }
        Rectangle {
            anchors.left: warningIcon.right
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 22
            y: 158
            height: 38
            color: "#F5F8FB"
            Rectangle { width: 3; color: Theme.warning; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom }
            Text {
                anchors.fill: parent
                anchors.leftMargin: 12
                verticalAlignment: Text.AlignVCenter
                text: root.resultDetail
                color: Theme.text700
                font.family: Theme.uiFont
                font.pixelSize: 12
            }
        }

        Rectangle {
            height: 64
            color: "#F8FAFC"
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            Rectangle { height: 1; color: Theme.border; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top }
            Row {
                spacing: 10
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                StyledButton {
                    id: closeAction
                    text: qsTr("关闭")
                    secondary: true
                    KeyNavigation.tab: retryAction
                    KeyNavigation.backtab: retryAction
                    onClicked: root.closed()
                }
                StyledButton {
                    id: retryAction
                    text: root.retryText
                    KeyNavigation.tab: closeAction
                    KeyNavigation.backtab: closeAction
                    onClicked: root.retryRequested()
                }
            }
        }
    }

    onVisibleChanged: if (visible) Qt.callLater(function() { retryAction.forceActiveFocus() })
}
