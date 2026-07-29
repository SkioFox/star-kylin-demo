import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import KylinSky 1.0

ApplicationWindow {
    visible: true
    width: 1280
    height: 800
    minimumWidth: 960
    minimumHeight: 600
    title: qsTr("麒麟工作台 v0.1.0")
    color: Theme.canvas

    Loader {
        anchors.fill: parent
        sourceComponent: !appController.configurationValid ? configurationErrorComponent
                         : appController.authenticated ? shellComponent : loginComponent
    }
    Component { id: loginComponent; LoginPage { } }
    Component { id: shellComponent; AppShell { } }
    Component { id: configurationErrorComponent; ConfigErrorPage { } }
}
