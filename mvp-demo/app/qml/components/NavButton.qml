import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Button {
    id: control
    property string iconName: ""
    property bool active: false

    implicitHeight: 44
    height: 44
    leftPadding: 20
    rightPadding: 12
    font.family: Theme.uiFont
    font.pixelSize: 14
    Accessible.name: text

    contentItem: Row {
        spacing: 12
        anchors.verticalCenter: parent.verticalCenter

        IconGlyph {
            iconName: control.iconName
            glyphColor: control.active ? Theme.goldLight : "#B7CBE0"
            glyphSize: 18
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: control.text
            color: control.active ? Theme.surface : "#C7D5E4"
            font: control.font
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        radius: 4
        color: control.active ? Theme.nav800 : control.hovered ? "#0D355F" : "transparent"
        border.width: control.activeFocus ? 2 : 0
        border.color: Theme.goldLight

        Rectangle {
            visible: control.active
            width: 3
            height: parent.height
            color: Theme.gold
            anchors.left: parent.left
        }
    }
}
