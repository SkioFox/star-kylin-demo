import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

ToolButton {
    id: control
    property string iconName: ""
    property color glyphColor: Theme.primary600
    property int glyphSize: 18

    implicitWidth: glyphSize
    implicitHeight: glyphSize
    width: implicitWidth
    height: implicitHeight
    padding: 0
    enabled: false
    opacity: 1
    focusPolicy: Qt.NoFocus
    display: AbstractButton.IconOnly
    icon.source: iconName.length > 0 ? Theme.iconSource(iconName) : ""
    icon.color: glyphColor
    icon.width: glyphSize
    icon.height: glyphSize
    background: Item { }
    Accessible.ignored: true
}
