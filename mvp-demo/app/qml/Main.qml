import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    minimumWidth: 820
    minimumHeight: 480
    title: qsTr("星麒业务工作台")
    color: Theme.canvas
    font.family: Theme.uiFont
    font.pixelSize: 14

    Loader {
        anchors.fill: parent
        sourceComponent: !appController.configurationValid
                         ? configErrorComponent
                         : appController.authenticated ? shellComponent : loginComponent
    }

    Component {
        id: loginComponent
        LoginPage { }
    }

    Component {
        id: shellComponent
        AppShell { }
    }

    Component {
        id: configErrorComponent
        ConfigErrorPage { }
    }
}
