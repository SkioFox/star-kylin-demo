import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Button {
    id: control
    property string moduleName: ""
    property string description: ""
    property string iconName: ""
    property string statusText: ""
    property color accent: Theme.primary600
    property color tint: Theme.primary050

    width: 286
    height: 162
    padding: 0
    Accessible.name: moduleName + "，" + description

    contentItem: Item {
        Rectangle {
            id: iconBox
            x: 20
            y: 20
            width: 44
            height: 44
            radius: 4
            color: control.tint
            IconGlyph {
                anchors.centerIn: parent
                iconName: control.iconName
                glyphColor: control.accent
                glyphSize: 22
            }
        }

        Text {
            id: title
            anchors.left: iconBox.right
            anchors.leftMargin: 14
            anchors.top: iconBox.top
            anchors.right: arrow.left
            anchors.rightMargin: 8
            text: control.moduleName
            color: Theme.text900
            font.family: Theme.uiFont
            font.pixelSize: 16
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        Text {
            anchors.left: title.left
            anchors.right: title.right
            anchors.top: title.bottom
            anchors.topMargin: 7
            text: control.description
            color: Theme.text600
            font.family: Theme.uiFont
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        IconGlyph {
            id: arrow
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 32
            iconName: "arrow-right"
            glyphColor: "#8194A8"
            glyphSize: 18
        }

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: 88
            height: 1
            color: "#E6EDF4"
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: 105
            spacing: 7

            Rectangle {
                width: 7
                height: 7
                radius: 4
                color: Theme.success
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                width: parent.width - 14
                text: control.statusText
                color: Theme.text600
                font.family: Theme.uiFont
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }
    }

    background: Rectangle {
        radius: 6
        color: control.hovered ? "#FBFDFF" : Theme.surface
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.primary600
                                                : control.hovered ? "#8FACCC" : Theme.border
        Rectangle {
            width: 3
            radius: 2
            color: control.accent
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
    }
}
