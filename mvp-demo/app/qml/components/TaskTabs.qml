import QtQuick 2.12
import QtQuick.Controls 2.5
import StarKylin 1.0

Rectangle {
    id: root
    height: 44
    color: "#EAF0F7"
    border.color: Theme.border

    function focusIndex(index) {
        if (index < 0 || index >= tabList.count) return
        tabList.currentIndex = index
        tabList.positionViewAtIndex(index, ListView.Contain)
        Qt.callLater(function() {
            if (tabList.currentItem) tabList.currentItem.tabButton.forceActiveFocus()
        })
    }

    ListView {
        id: tabList
        anchors.fill: parent
        orientation: ListView.Horizontal
        clip: true
        model: appController.tabModel
        currentIndex: appController.tabModel.indexOf(appController.activeModuleId)

        delegate: Rectangle {
            id: tabDelegate
            property alias tabButton: mainButton
            width: Math.min(190, Math.max(112, label.implicitWidth + (model.closable ? 92 : 66)))
            height: tabList.height
            color: model.active ? Theme.surface : mainButton.hovered ? "#F4F7FB" : "transparent"
            border.width: model.active ? 1 : 0
            border.color: Theme.border

            Button {
                id: mainButton
                anchors.left: parent.left
                anchors.right: model.closable ? closeButton.left : parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                padding: 0
                focusPolicy: Qt.StrongFocus
                Accessible.name: model.name
                onClicked: appController.activateTab(model.id)
                Keys.onPressed: {
                    if (event.key === Qt.Key_Left) root.focusIndex(Math.max(0, index - 1))
                    else if (event.key === Qt.Key_Right) root.focusIndex(Math.min(tabList.count - 1, index + 1))
                    else if (event.key === Qt.Key_Home) root.focusIndex(0)
                    else if (event.key === Qt.Key_End) root.focusIndex(tabList.count - 1)
                    else return
                    event.accepted = true
                }

                contentItem: Row {
                    anchors.centerIn: parent
                    spacing: 8
                    IconGlyph {
                        iconName: model.iconName
                        glyphColor: model.active ? Theme.primary700 : Theme.text600
                        glyphSize: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        id: label
                        text: model.name
                        color: model.active ? Theme.primary700 : Theme.text600
                        font.family: Theme.uiFont
                        font.pixelSize: 13
                        font.weight: model.active ? Font.DemiBold : Font.Normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                background: Item { }
            }

            IconButton {
                id: closeButton
                visible: model.closable
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                iconName: "x"
                toolTip: qsTr("关闭") + model.name
                glyphColor: hovered ? Theme.danger : Theme.text600
                onClicked: {
                    appController.closeTab(model.id)
                    Qt.callLater(function() {
                        root.focusIndex(appController.tabModel.indexOf(appController.activeModuleId))
                    })
                }
            }

            Rectangle {
                visible: model.active
                height: 2
                color: Theme.primary600
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }
        }
    }
}
