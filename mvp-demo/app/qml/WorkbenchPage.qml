import QtQuick 2.12
import StarKylin 1.0
import "components"

Flickable {
    id: root
    clip: true
    contentWidth: width
    contentHeight: content.height + 48

    function displayDate() {
        var value = new Date()
        var weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
        return Qt.formatDate(value, "yyyy-MM-dd") + " · " + weekdays[value.getDay()]
    }

    Item {
        id: content
        x: root.width < 900 ? 16 : 24
        y: root.width < 900 ? 16 : 20
        width: root.width - x * 2
        height: facts.y + facts.height

        Text {
            id: heading
            text: qsTr("工作台")
            color: Theme.text900
            font.family: Theme.uiFont
            font.pixelSize: 24
            font.weight: Font.DemiBold
        }
        Text {
            id: subtitle
            anchors.left: heading.left
            anchors.top: heading.bottom
            anchors.topMargin: 5
            text: appController.currentRole + qsTr("当前可用的授权业务入口")
            color: Theme.text600
            font.family: Theme.uiFont
            font.pixelSize: 14
        }
        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 3
            text: root.displayDate()
            color: Theme.text600
            font.family: Theme.dataFont
            font.pixelSize: 12
        }

        Row {
            id: sectionTitle
            anchors.left: parent.left
            anchors.top: subtitle.bottom
            anchors.topMargin: 24
            spacing: 10
            Rectangle { width: 3; height: 16; color: Theme.gold; anchors.verticalCenter: parent.verticalCenter }
            Text { text: qsTr("可用应用"); color: Theme.text700; font.family: Theme.uiFont; font.pixelSize: 14; font.weight: Font.DemiBold }
        }

        Flow {
            id: cards
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: sectionTitle.bottom
            anchors.topMargin: 12
            spacing: 16
            height: childrenRect.height

            Repeater {
                model: appController.moduleModel
                delegate: ModuleCard {
                    width: Math.min(286, cards.width)
                    enabled: model.type !== "native" || !appController.nativeLaunchPending
                    moduleName: model.name
                    description: model.description
                    iconName: model.iconName
                    statusText: model.status
                    accent: model.accent
                    tint: model.tint
                    onClicked: appController.openModule(model.id)
                }
            }
        }

        Row {
            id: facts
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: cards.bottom
            anchors.topMargin: visible ? 24 : 0
            visible: root.height >= 430
            height: visible ? 82 : 0

            Repeater {
                model: [
                    { label: "当前身份", value: appController.currentDisplayName + " · " + appController.currentRole },
                    { label: "数据边界", value: "本地 Mock 数据" },
                    { label: "授权模块", value: appController.moduleModel.count + " 个业务入口" }
                ]
                delegate: Item {
                    width: facts.width / 3
                    height: facts.height
                    Rectangle { height: 1; color: Theme.border; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top }
                    Rectangle { height: 1; color: Theme.border; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom }
                    Rectangle { visible: index < 2; width: 1; height: 44; color: Theme.border; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter }
                    Text { x: index === 0 ? 0 : 18; y: 17; width: parent.width - x - 18; text: modelData.label; color: Theme.text600; font.family: Theme.uiFont; font.pixelSize: 12; elide: Text.ElideRight }
                    Text { x: index === 0 ? 0 : 18; y: 42; width: parent.width - x - 18; text: modelData.value; color: Theme.text700; font.family: Theme.uiFont; font.pixelSize: 14; font.weight: Font.DemiBold; elide: Text.ElideRight }
                }
            }
        }
    }
}
