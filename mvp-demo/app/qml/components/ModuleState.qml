import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Item {
    id: root
    property string iconName: "triangle-alert"
    property string title: ""
    property string detail: ""
    property string actionText: ""
    property color tone: Theme.danger
    property color toneBackground: Theme.dangerSoft
    signal actionTriggered()

    Column {
        width: Math.min(480, root.width - 48)
        anchors.centerIn: parent
        spacing: 0

        Rectangle {
            width: 56
            height: 56
            radius: 28
            color: root.toneBackground
            anchors.horizontalCenter: parent.horizontalCenter
            IconGlyph {
                anchors.centerIn: parent
                iconName: root.iconName
                glyphColor: root.tone
                glyphSize: 26
            }
        }
        Text {
            width: parent.width
            topPadding: 18
            text: root.title
            color: Theme.text900
            font.family: Theme.uiFont
            font.pixelSize: 20
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
        Text {
            width: parent.width
            topPadding: 10
            bottomPadding: root.actionText.length > 0 ? 22 : 0
            text: root.detail
            color: Theme.text600
            font.family: Theme.uiFont
            font.pixelSize: 14
            lineHeight: 1.5
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
        StyledButton {
            visible: root.actionText.length > 0
            text: root.actionText
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: root.actionTriggered()
        }
    }
}
