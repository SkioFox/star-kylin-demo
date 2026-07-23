import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Button {
    id: control
    property bool secondary: false

    implicitWidth: Math.max(96, contentItem.implicitWidth + 32)
    implicitHeight: 44
    leftPadding: 16
    rightPadding: 16
    font.family: Theme.uiFont
    font.pixelSize: 14
    font.weight: Font.DemiBold

    contentItem: Text {
        text: control.text
        color: !control.enabled ? "#93A1B1" : control.secondary ? Theme.primary700 : Theme.surface
        font: control.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 4
        color: {
            if (!control.enabled) return control.secondary ? Theme.surfaceMuted : "#A7BCD2"
            if (control.secondary) return control.down ? Theme.primary100 : control.hovered ? Theme.primary050 : Theme.surface
            return control.down ? Theme.primary700 : control.hovered ? Theme.primary700 : Theme.primary600
        }
        border.width: control.activeFocus ? 2 : 1
        border.color: control.activeFocus ? Theme.primary600
                                                : control.secondary ? Theme.borderStrong : color
    }
}
