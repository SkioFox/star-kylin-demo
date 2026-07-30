import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property bool streamPaused: false

    Rectangle {
        anchors.fill: parent; color: Theme.canvas
        Row {
            anchors.fill: parent; spacing: 0
            Column {
                width: parent.width - contextPanel.width; height: parent.height; spacing: 0
                Rectangle {
                    width: parent.width; height: 72; color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                    Item { anchors.fill: parent; anchors.margins: 18
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("原生行情中心"); color: Theme.ink; font.pixelSize: Math.round(18 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("原生图表 / 本地演示数据 / 实时渲染"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale) }
                        }
                        Row { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: 8
                            Rectangle { width: 7; height: 7; radius: 4; color: root.streamPaused ? Theme.gold : Theme.signal }
                            Text { text: root.streamPaused ? qsTr("行情流已暂停") : qsTr("行情流已连接"); color: Theme.accentText; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                        }
                    }
                }
                KlinePanel {
                    width: parent.width - 28; height: Math.max(330, parent.height - 111)
                    anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 11
                    instrumentId: "hs300"; titleText: qsTr("原生图表视图")
                }
                Rectangle {
                    width: parent.width; height: 44; color: Theme.surfaceSoft; border.width: 1; border.color: Theme.line
                    Row { anchors.fill: parent; anchors.margins: 16; spacing: 16
                        Text { text: qsTr("本地高刷新图表，支持滚轮缩放、拖拽平移及键盘 + / − / R。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); anchors.verticalCenter: parent.verticalCenter }
                        Button {
                            id: pauseButton; width: 92; height: Theme.toolHeight - 2; text: root.streamPaused ? qsTr("恢复刷新") : qsTr("暂停刷新")
                            onClicked: root.streamPaused = !root.streamPaused
                            contentItem: Text { text: pauseButton.text; color: pauseButton.hovered ? Theme.ink : Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: pauseButton.hovered ? Theme.surface : "transparent"; border.width: 1; border.color: pauseButton.activeFocus ? Theme.signal : Theme.line }
                        }
                    }
                }
            }
            Rectangle {
                id: contextPanel; width: 316; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                Column { anchors.fill: parent; spacing: 0
                    Rectangle { width: parent.width; height: 64; color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                        Column { anchors.left: parent.left; anchors.leftMargin: 16; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("当前蜡烛"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                            Text { text: qsTr("沪深 300"); color: Theme.ink; font.pixelSize: Math.round(18 * Theme.textScale); font.bold: true }
                        }
                    }
                    Column { width: parent.width; padding: 16; spacing: 10
                        Repeater { model: [{k:qsTr("时间"),v:"14:55"},{k:qsTr("开盘 / 最高"),v:"3,824.0 / 3,840.2"},{k:qsTr("最低 / 收盘"),v:"3,812.4 / 3,821.4"},{k:qsTr("MA5 / MA10"),v:"3,830.5 / 3,842.1"}]
                            delegate: Column { width: parent.width; spacing: 3; Text { text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) } Text { text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont } }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { width: parent.width; text: qsTr("原生图表支持缩放、平移和指标叠加。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                    }
                }
            }
        }
    }
}
