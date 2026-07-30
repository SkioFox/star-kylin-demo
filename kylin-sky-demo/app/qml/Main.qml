import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import KylinSky 1.0

ApplicationWindow {
    visible: true
    visibility: Window.Maximized
    width: 1280
    height: 800
    minimumWidth: 1180
    minimumHeight: 680
    title: qsTr("麒麟工作台 v%1").arg(applicationVersion)
    color: Theme.canvas
    font.family: Theme.uiFont
    font.pixelSize: Math.round(13 * Theme.textScale)

    Loader {
        anchors.fill: parent
        sourceComponent: !appController.configurationValid ? configurationErrorComponent
                         : appController.authenticated ? shellComponent : loginComponent
    }
    Component { id: loginComponent; LoginPage { } }
    Component { id: shellComponent; AppShell { } }
    Component { id: configurationErrorComponent; ConfigErrorPage { } }
}
