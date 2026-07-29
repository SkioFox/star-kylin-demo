import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import KylinSky 1.0

Item {
    id: root
    property string selectedCode: ""
    property string selectedName: ""
    property string selectedSector: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    readonly property bool hasSelection: selectedCode.length > 0
    readonly property string selectedInstrument: selectedCode === "399986" ? "bank-index" : "hs300"

    function selectInstrument(code, name, sector, price, change) {
        selectedCode = code
        selectedName = name
        selectedSector = sector
        selectedPrice = price
        selectedChange = change
    }
    function selectDefault() {
        if (root.hasSelection || !marketData.ready) return
        var item = marketData.model.firstForMarket("国内")
        if (item && item.code) root.selectInstrument(item.code, item.name, item.category, item.price, item.change)
    }
    Component.onCompleted: selectDefault()
    Connections {
        target: marketData
        function onStateChanged() { root.selectDefault() }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            Rectangle {
                Layout.preferredWidth: 192
                Layout.fillHeight: true
                color: Theme.surface
                border.color: Theme.line
                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    Label { text: qsTr("研究对象"); color: Theme.ink; font.bold: true; font.pixelSize: 15 }
                    Label { text: qsTr("包内国内标的"); color: Theme.muted; font.pixelSize: 11 }
                    ListView {
                        id: instruments
                        width: parent.width
                        height: parent.height - 62
                        model: marketData.model
                        clip: true
                        spacing: 3
                        delegate: Button {
                            width: instruments.width
                            height: market === "国内" ? 56 : 0
                            visible: height > 0
                            highlighted: root.selectedCode === code
                            onClicked: root.selectInstrument(code, name, category, price, change)
                            contentItem: Column {
                                leftPadding: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                Text { text: name; color: parent.parent.highlighted ? Theme.primary : Theme.ink; font.pixelSize: 13; font.bold: true }
                                Text { text: code + " · " + category; color: Theme.muted; font.pixelSize: 10 }
                            }
                            background: Rectangle { color: parent.highlighted ? "#E8F2FB" : parent.hovered ? "#F6FAFD" : Theme.surface; border.color: parent.highlighted ? Theme.primary : Theme.line }
                        }
                    }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.surface
                border.color: Theme.line
                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    Row {
                        width: parent.width
                        visible: root.hasSelection
                        Column {
                            spacing: 3
                            Label { text: root.selectedName + "  " + root.selectedCode; color: Theme.ink; font.pixelSize: 20; font.bold: true }
                            Label { text: qsTr("本地原生图表 · 演示数据 · 不构成投资建议"); color: Theme.muted; font.pixelSize: 11 }
                        }
                        Column {
                            anchors.right: parent.right
                            spacing: 2
                            Label { anchors.right: parent.right; text: Number(root.selectedPrice).toFixed(root.selectedPrice >= 1000 ? 2 : 3); color: Theme.ink; font.pixelSize: 22; font.family: "Monospace" }
                            Label { anchors.right: parent.right; text: (root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%"; color: root.selectedChange >= 0 ? Theme.up : Theme.down; font.bold: true }
                        }
                    }
                    KlinePanel { visible: root.hasSelection; width: parent.width; height: visible ? 360 : 0; instrumentId: root.selectedInstrument }
                    Row {
                        visible: root.hasSelection
                        width: parent.width
                        spacing: 10
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 94
                            color: "#F8FAFC"
                            border.color: Theme.line
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 5
                                Label { text: qsTr("资金与指标"); color: Theme.ink; font.bold: true; font.pixelSize: 12 }
                                Label { text: qsTr("量能较过去 5 日均值活跃 · MACD 演示信号待确认"); color: Theme.muted; font.pixelSize: 11; wrapMode: Text.Wrap; width: parent.width }
                            }
                        }
                        Rectangle {
                            width: (parent.width - 10) / 2
                            height: 94
                            color: "#F8FAFC"
                            border.color: Theme.line
                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 5
                                Label { text: qsTr("关联资讯"); color: Theme.ink; font.bold: true; font.pixelSize: 12 }
                                Label { text: qsTr("10:22 行业成交活跃，关注量价匹配\n09:48 研究摘要已更新"); color: Theme.muted; font.pixelSize: 11; lineHeight: 1.35 }
                            }
                        }
                    }
                    Label { visible: !root.hasSelection; anchors.horizontalCenter: parent.horizontalCenter; width: Math.min(360, parent.width); anchors.verticalCenter: parent.verticalCenter; text: qsTr("从左侧选择一个国内标的，报价、图表和研究上下文将同步更新。"); color: Theme.muted; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter; lineHeight: 1.45 }
                }
            }
            Rectangle {
                Layout.preferredWidth: 244
                Layout.fillHeight: true
                color: Theme.surface
                border.color: Theme.line
                Column {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10
                    Label { text: qsTr("研究上下文"); color: Theme.ink; font.bold: true; font.pixelSize: 15 }
                    Label { text: root.hasSelection ? qsTr("五档行情") : qsTr("等待选择标的"); color: Theme.muted; font.pixelSize: 11 }
                    Repeater {
                        visible: root.hasSelection
                        model: ["卖五  11.58    2,340", "卖四  11.57    1,806", "卖三  11.56    3,215", "卖二  11.55    2,091", "卖一  11.54    1,268", "买一  11.53    1,922", "买二  11.52    2,675", "买三  11.51    1,438", "买四  11.50    3,016", "买五  11.49    1,752"]
                        delegate: Label { width: parent.width; text: modelData; color: index < 5 ? Theme.up : Theme.down; font.family: "Monospace"; font.pixelSize: 11 }
                    }
                    Rectangle { visible: root.hasSelection; width: parent.width; height: 1; color: Theme.line }
                    Label { visible: root.hasSelection; text: qsTr("关联板块"); color: Theme.ink; font.bold: true; font.pixelSize: 12 }
                    Label { visible: root.hasSelection; width: parent.width; text: root.selectedSector + qsTr(" · 仅展示本地演示关联关系"); color: Theme.muted; wrapMode: Text.Wrap; font.pixelSize: 11 }
                }
            }
        }
    }
}
