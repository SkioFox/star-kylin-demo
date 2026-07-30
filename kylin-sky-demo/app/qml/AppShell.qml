import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import KylinSky 1.0

Item {
    id: root
    property string currentId: appController.activeModuleId
    property string currentTitle: appController.activeModuleName.length ? appController.activeModuleName : qsTr("工作台")
    readonly property var groups: [qsTr("市场观察"), qsTr("应用服务"), qsTr("原生能力")]
    focus: true

    Keys.onEscapePressed: appController.activateTab("workbench")

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Rectangle {
            id: commandRail
            height: Theme.shellRailHeight
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.command
            border.width: 1
            border.color: Theme.line

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                spacing: 11
                Rectangle {
                    width: 31; height: 31
                    color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                    Image { anchors.centerIn: parent; width: 18; height: 18; source: "qrc:/icons/landmark.svg"; fillMode: Image.PreserveAspectFit }
                }
                Text { text: qsTr("麒麟工作台"); color: "#FFFFFF"; font.pixelSize: Math.round(16 * Theme.textScale); font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 1; height: 22; color: Theme.softLine; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("运营与研究工作区 · v%1").arg(applicationVersion); color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); anchors.verticalCenter: parent.verticalCenter }
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle {
                    height: Theme.controlHeight; width: 136
                    color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                    Row { anchors.centerIn: parent; spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: Theme.gold; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: appController.displayRole + qsTr(" / 受控环境"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); elide: Text.ElideRight; width: 112; verticalAlignment: Text.AlignVCenter }
                    }
                }
                Rectangle {
                    height: Theme.controlHeight; width: 86
                    color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                    Row { anchors.centerIn: parent; spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: Theme.signal; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: qsTr("服务 6 / 7"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                    }
                }
                Rectangle {
                    height: Theme.controlHeight; width: 96
                    color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                    Row { anchors.centerIn: parent; spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: Theme.signal; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: qsTr("网络正常"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                    }
                }
                Button {
                    id: logoutButton
                    width: 82; height: Theme.controlHeight
                    text: qsTr("退出会话")
                    onClicked: appController.logout()
                    contentItem: Text { text: logoutButton.text; color: "#E8F2FA"; font.pixelSize: Math.round(11 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: logoutButton.down ? Theme.panelBlue : logoutButton.hovered ? Theme.panelBlue : "transparent"; border.width: 1; border.color: logoutButton.activeFocus || logoutButton.hovered ? Theme.signal : Theme.line }
                }
            }
        }

        Rectangle {
            id: sidebar
            width: Theme.sidebarWidth
            anchors.top: commandRail.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: Theme.rail
            border.width: 1
            border.color: Theme.line

            Column {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 2
                Repeater {
                    model: root.groups
                    delegate: Item {
                        width: parent.width
                        property string groupName: modelData
                        height: groupColumn.implicitHeight + (index === 0 ? 0 : 10)
                        Column {
                            id: groupColumn
                            width: parent.width
                            anchors.top: parent.top
                            anchors.topMargin: index === 0 ? 0 : 10
                            spacing: 2
                            Text { text: groupName; leftPadding: 10; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); font.bold: true }
                            Repeater {
                                model: appController.moduleModel
                                delegate: Button {
                                    id: navigationButton
                                    visible: !!group && group === groupName
                                    width: parent.width
                                    height: visible ? Theme.navigationRowHeight : 0
                                    text: title
                                    highlighted: root.currentId === moduleId
                                    onClicked: appController.openModule(moduleId)
                                    contentItem: Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 10
                                        text: navigationButton.text
                                        color: navigationButton.highlighted ? Theme.ink : Theme.labelMuted
                                        font.pixelSize: Math.round(13 * Theme.textScale)
                                        verticalAlignment: Text.AlignVCenter
                                        horizontalAlignment: Text.AlignLeft
                                        elide: Text.ElideRight
                                    }
                                    background: Rectangle {
                                        color: navigationButton.highlighted ? Theme.railActive : navigationButton.hovered ? Theme.railHover : "transparent"
                                        border.width: navigationButton.highlighted ? 1 : 0
                                        border.color: Theme.line
                                        Rectangle { visible: navigationButton.highlighted; width: 3; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; color: Theme.signal }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            anchors.top: commandRail.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.tabsHeight
                color: Theme.panelBlueDark
                border.width: 1
                border.color: Theme.line
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    spacing: 1
                    Repeater {
                        model: appController.tabModel
                        delegate: Button {
                            id: taskTab
                            height: parent.height
                            width: Math.max(108, taskLabel.implicitWidth + (closable ? 43 : 28))
                            text: title
                            highlighted: active
                            onClicked: appController.activateTab(moduleId)
                            Keys.onPressed: function(event) {
                                if (closable && (event.key === Qt.Key_Delete || (event.key === Qt.Key_W && (event.modifiers & Qt.ControlModifier)))) {
                                    appController.closeTab(moduleId)
                                    event.accepted = true
                                }
                            }
                            contentItem: Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 9
                                spacing: 7
                                Text { id: taskLabel; width: Math.max(42, parent.width - (closable ? 28 : 0)); height: parent.height; text: taskTab.text; color: taskTab.highlighted ? Theme.ink : Theme.labelMuted; font.pixelSize: Math.round(12 * Theme.textScale); verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { visible: closable; height: parent.height; text: "×"; color: taskTab.highlighted ? Theme.signal : Theme.label; font.pixelSize: Math.round(15 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                            }
                            background: Rectangle {
                                color: taskTab.highlighted ? Theme.railActive : taskTab.hovered ? Theme.panelBlue : "transparent"
                                border.width: taskTab.activeFocus ? 1 : 0
                                border.color: Theme.signal
                                Rectangle { visible: taskTab.highlighted; height: 3; anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; color: Theme.signal }
                            }
                            MouseArea {
                                anchors.right: parent.right
                                width: closable ? 28 : 0
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                enabled: closable
                                onClicked: appController.closeTab(moduleId)
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.contextHeight
                color: Theme.panelBlueDark
                border.width: 1
                border.color: Theme.line
                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 18
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Text { text: qsTr("工作台"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                    Text { text: "/"; color: Theme.muted; font.pixelSize: Math.round(12 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                    Text { text: root.currentTitle; color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight; width: 300 }
                }
                Text { anchors.right: parent.right; anchors.rightMargin: 18; anchors.verticalCenter: parent.verticalCenter; text: qsTr("本地演示数据"); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Item {
                    anchors.fill: parent
                    visible: root.currentId === "workbench"
                    Rectangle { anchors.fill: parent; color: Theme.canvas }
                    Column {
                        anchors.fill: parent
                        anchors.margins: Theme.contentPadding
                        spacing: 12
                        Rectangle {
                            width: parent.width; height: 84
                            color: Theme.surface; border.width: 1; border.color: Theme.line
                            Row { anchors.fill: parent; anchors.margins: 16; spacing: 24
                                Column { width: 300; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                                    Text { text: qsTr("工作台"); color: Theme.ink; font.pixelSize: Math.round(20 * Theme.textScale); font.bold: true }
                                    Text { text: qsTr("从已授权模块继续处理当前工作。 "); color: Theme.muted; font.pixelSize: Math.round(12 * Theme.textScale) }
                                }
                                Repeater { model: [{k:"服务",v:"6 / 7",d:"本地状态已加载"},{k:"会话",v:"有效",d:"当前内存会话"},{k:"网络",v:"正常",d:"受控环境"}]
                                    delegate: Column { width: 126; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                        Text { text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                                        Text { text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(17 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                        Text { text: modelData.d; color: Theme.down; font.pixelSize: Math.round(10 * Theme.textScale) }
                                    }
                                }
                            }
                        }
                        Row { spacing: 12
                            Repeater { model: [{id:"watchlist",name:"自选",detail:"扫描关注标的与热点"},{id:"research",name:"个股研究",detail:"打开研究对象和原生图表"},{id:"web",name:"指定业务",detail:"进入受控外汇演示台"}]
                                delegate: Button {
                                    width: 260; height: 116; text: modelData.name
                                    onClicked: appController.openModule(modelData.id)
                                    contentItem: Column { anchors.fill: parent; anchors.margins: 15; spacing: 8
                                        Text { text: modelData.name; color: Theme.ink; font.pixelSize: Math.round(16 * Theme.textScale); font.bold: true }
                                        Text { width: parent.width; text: modelData.detail; color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); wrapMode: Text.Wrap }
                                        Text { text: qsTr("打开任务  →"); color: Theme.label; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont }
                                    }
                                    background: Rectangle { color: parent.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: parent.activeFocus ? Theme.signal : Theme.line }
                                }
                            }
                        }
                    }
                }

                MarketWorkspace { anchors.fill: parent; moduleId: root.currentId; visible: root.currentId === "watchlist" }
                ResearchWorkspace { anchors.fill: parent; visible: root.currentId === "research" }
                MarketOverviewWorkspace { anchors.fill: parent; visible: root.currentId === "market" }
                GlobalWorkspace { anchors.fill: parent; visible: root.currentId === "global" }
                FuturesWorkspace { anchors.fill: parent; visible: root.currentId === "futures" }
                GoldWorkspace { anchors.fill: parent; visible: root.currentId === "gold" }
                Loader { id: webLoader; anchors.fill: parent; active: appController.isWebModule(root.currentId); sourceComponent: webModulePage }
                NativeMarketWorkspace { anchors.fill: parent; visible: root.currentId === "native-market" }
                ServicePage { anchors.fill: parent; moduleId: root.currentId; visible: ["network", "native-integration"].indexOf(root.currentId) >= 0 }
                Column {
                    anchors.centerIn: parent
                    visible: root.currentId !== "workbench" && ["watchlist", "research", "market", "global", "futures", "gold", "web", "external", "network", "native-market", "native-integration"].indexOf(root.currentId) < 0
                    spacing: 10
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: root.currentTitle; color: Theme.ink; font.pixelSize: Math.round(22 * Theme.textScale); font.bold: true }
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("该模块暂未配置可展示内容。 "); color: Theme.muted }
                }
            }
        }
    }

    Component { id: webModulePage; WebModulePage { moduleId: root.currentId } }
}
