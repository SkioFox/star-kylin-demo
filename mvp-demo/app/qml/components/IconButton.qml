import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

ToolButton {
    id: control
    property string iconName: ""
    property string toolTip: ""
    property color glyphColor: enabled ? Theme.text700 : "#A6B2BF"

    implicitWidth: 44
    implicitHeight: 44
    width: 44
    height: 44
    padding: 0
    display: AbstractButton.IconOnly
    icon.source: iconName.length > 0 ? Theme.iconSource(iconName) : ""
    icon.color: glyphColor
    icon.width: 19
    icon.height: 19
    Accessible.name: toolTip

    ToolTip.visible: hovered && toolTip.length > 0
    ToolTip.text: toolTip
    ToolTip.delay: 450

    background: Rectangle {
        radius: 4
        color: control.enabled && (control.hovered || control.down) ? Theme.primary050 : "transparent"
        border.width: control.activeFocus ? 2 : 0
        border.color: Theme.primary600
    }
}
