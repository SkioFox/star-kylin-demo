import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import KylinSky 1.0

Item {
    signal logoutRequested()
    property string currentId: appController.activeModuleId
    property string currentTitle: appController.activeModuleName.length > 0 ? appController.activeModuleName : qsTr("工作台")
    focus: true
    Keys.onEscapePressed: appController.activateTab("workbench")
    Rectangle {
        anchors.fill: parent; color: Theme.canvas
        Rectangle { id: rail; height: 42; anchors.left: parent.left; anchors.right: parent.right; color: Theme.nav
            Row {
                anchors.left: parent.left; anchors.leftMargin: 18; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 12
                Text { text: qsTr("麒麟工作台"); color: "#FFFFFF"; font.pixelSize: 14; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                Rectangle { width: 1; height: 16; color: "#5B7C9D"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("运营与研究工作区 · v0.1.0"); color: "#C8D8E7"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                Item { width: Math.max(0, parent.width - 530); height: 1 }
                Text { width: 185; text: appController.displayRole + qsTr(" · 服务 6/7 · 网络正常"); color: "#DCE8F2"; font.pixelSize: 12; elide: Text.ElideRight; horizontalAlignment: Text.AlignRight; anchors.verticalCenter: parent.verticalCenter }
                Button {
                    id: logout; width: 58; height: 28; text: qsTr("退出"); onClicked: appController.logout()
                    contentItem: Text { text: logout.text; color: "#E4EEF7"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { radius: 2; color: logout.down ? "#145886" : logout.hovered ? "#104A78" : "transparent"; border.width: 1; border.color: logout.activeFocus ? "#D2A75D" : "#6B91B2" }
                }
            }
        }
        Rectangle { id: sidebar; width: 216; anchors.top: rail.bottom; anchors.bottom: parent.bottom; color: Theme.nav
            ListView { anchors.fill: parent; anchors.margins: 9; model: appController.moduleModel; spacing: 4; clip: true
                delegate: Button { width: ListView.view.width; height: 38; text: title; highlighted: currentId === moduleId; onClicked: appController.openModule(moduleId)
                    contentItem: Text { text: parent.text; color: "#E4EEF7"; verticalAlignment: Text.AlignVCenter; leftPadding: 12; font.pixelSize: 14 }
                    background: Rectangle { color: parent.highlighted ? "#10558C" : parent.hovered ? "#104A78" : "transparent"; border.color: parent.highlighted ? "#286D9F" : "transparent" }
                }
            }
        }
        ColumnLayout { anchors.top: rail.bottom; anchors.left: sidebar.right; anchors.right: parent.right; anchors.bottom: parent.bottom; spacing: 0
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 42; color: "#EEF3F8"
                Row { anchors.fill: parent; anchors.leftMargin: 14; spacing: 2
                    Repeater { model: appController.tabModel; delegate: Button { height: parent.height; width: Math.max(78, tabText.implicitWidth + 28); text: title + (closable ? "  ×" : ""); highlighted: active; onClicked: appController.activateTab(moduleId); onPressAndHold: appController.closeTab(moduleId)
                        Keys.onPressed: function(event) { if (closable && (event.key === Qt.Key_Delete || (event.key === Qt.Key_W && (event.modifiers & Qt.ControlModifier)))) { appController.closeTab(moduleId); event.accepted = true } }
                        contentItem: Text { id: tabText; text: parent.text; color: parent.highlighted ? Theme.primary : Theme.ink; font.pixelSize: 13; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                        background: Rectangle { color: parent.highlighted ? Theme.surface : "transparent"; border.color: parent.highlighted ? Theme.primary : "transparent" }
                    } }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 46; color: Theme.surface; border.color: Theme.line
                Row { anchors.left: parent.left; anchors.leftMargin: 18; anchors.right: parent.right; anchors.rightMargin: 18; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                    Text { text: qsTr("工作台"); color: Theme.muted; font.pixelSize: 13 }
                    Text { text: "›"; color: Theme.muted; font.pixelSize: 15 }
                    Text { width: Math.min(260, Math.max(96, parent.width - 250)); text: currentTitle; color: Theme.ink; font.pixelSize: 13; font.bold: true; elide: Text.ElideRight }
                    Text { text: qsTr("当前任务上下文"); color: Theme.muted; font.pixelSize: 12 }
                }
            }
            Rectangle { Layout.fillWidth: true; Layout.fillHeight: true; color: Theme.canvas
                Item { anchors.fill: parent; visible: currentId === "workbench"
                    Column { anchors.fill: parent; anchors.margins: 18; spacing: 14
                        Row { spacing: 10
                            Label { text: qsTr("常用任务"); color: Theme.ink; font.pixelSize: 18; font.bold: true }
                            Label { text: qsTr("从最近工作上下文继续"); color: Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                        }
                        Grid { columns: 3; spacing: 12
                            Repeater { model: [{id:"watchlist",name:"自选",detail:"8 个关注标的，行情订阅稳定"},{id:"research",name:"个股研究",detail:"中证银行 · 最近打开于 10:22"},{id:"web",name:"指定业务",detail:"受控业务入口，来源策略已加载"}]
                                delegate: Button { width: 250; height: 112; text: modelData.name + "\n" + modelData.detail; onClicked: appController.openModule(modelData.id)
                                    contentItem: Text { text: parent.text; color: Theme.ink; leftPadding: 16; rightPadding: 16; verticalAlignment: Text.AlignVCenter; wrapMode: Text.Wrap; lineHeight: 1.4 }
                                    background: Rectangle { color: parent.hovered ? "#F7FBFE" : Theme.surface; border.color: Theme.line }
                                }
                            }
                        }
                        Rectangle { width: parent.width; height: 88; color: Theme.surface; border.color: Theme.line
                            Row { anchors.fill: parent; anchors.margins: 14; spacing: 36
                                Column { Label { text: qsTr("服务状态"); color: Theme.muted } Label { text: qsTr("行情订阅稳定"); color: Theme.ink; font.bold: true } }
                                Column { Label { text: qsTr("指定业务"); color: Theme.muted } Label { text: qsTr("批准配置已加载"); color: Theme.ink; font.bold: true } }
                                Column { Label { text: qsTr("网络验证"); color: Theme.muted } Label { text: qsTr("等待发起检查"); color: Theme.ink; font.bold: true } }
                            }
                        }
                    }
                }
                MarketWorkspace { anchors.fill: parent; moduleId: currentId; visible: ["watchlist", "market", "global", "futures", "gold"].indexOf(currentId) >= 0 }
                ResearchWorkspace { anchors.fill: parent; visible: currentId === "research" }
                Loader { anchors.fill: parent; active: appController.isWebModule(currentId); sourceComponent: webModulePage }
                ServicePage { anchors.fill: parent; moduleId: currentId; visible: ["network", "native-market"].indexOf(currentId) >= 0 }
                Column { anchors.centerIn: parent; visible: currentId !== "workbench" && ["watchlist", "research", "market", "global", "futures", "gold", "web", "external", "network", "native-market"].indexOf(currentId) < 0; spacing: 10
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: currentTitle; color: Theme.ink; font.pixelSize: 22; font.bold: true }
                    Label { anchors.horizontalCenter: parent.horizontalCenter; text: qsTr("模块内容将在受控容器接入后显示。"); color: Theme.muted }
                }
            }
        }
    }

    Component { id: webModulePage; WebModulePage { moduleId: currentId } }
}
