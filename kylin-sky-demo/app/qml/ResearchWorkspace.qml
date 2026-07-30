import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string selectedId: ""
    property string selectedCode: ""
    property string selectedName: ""
    property string selectedSector: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    readonly property bool hasSelection: selectedId.length > 0

    function selectInstrument(instrumentId, code, name, sector, price, change) {
        selectedId = instrumentId
        selectedCode = code
        selectedName = name
        selectedSector = sector
        selectedPrice = price
        selectedChange = change
    }
    function selectDefault() {
        if (root.hasSelection || !marketData.ready) return
        var item = marketData.model.firstForMarket("国内", "pingan")
        if (item && item.code) {
            var codeToId = {"000300":"hs300", "399986":"bank-index", "000001":"pingan", "300750":"ningde"}
            root.selectInstrument(item.instrumentId || codeToId[item.code] || "hs300", item.code, item.name, item.category, item.price, item.change)
        }
    }
    function priceAt(offset) {
        var value = root.selectedPrice + offset
        return value >= 1000 ? value.toFixed(2) : value.toFixed(2)
    }
    Component.onCompleted: selectDefault()
    Connections { target: marketData; function onStateChanged() { root.selectDefault() } }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Row {
            anchors.fill: parent
            anchors.margins: Theme.contentPadding
            spacing: 10

            Rectangle {
                id: objectPool
                width: 236; height: parent.height
                color: Theme.surface
                border.width: 1; border.color: Theme.line
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 70; color: Theme.panelBlue
                        border.width: 1; border.color: Theme.line
                        Column { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("研究对象"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                            Text { text: qsTr("个股研究"); color: "#FFFFFF"; font.pixelSize: Math.round(17 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("国内标的 · 原生分析画布"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale) }
                        }
                    }
                    ListView {
                        id: instruments
                        width: parent.width; height: parent.height - 70
                        model: marketData.model
                        clip: true; spacing: 0
                        delegate: Button {
                            id: researchRow
                            width: instruments.width
                            height: market === "国内" ? 76 : 0
                            visible: height > 0
                            highlighted: root.selectedId === instrumentId
                            onClicked: root.selectInstrument(instrumentId, code, name, category, price, change)
                            contentItem: Column { anchors.fill: parent; anchors.margins: 11; spacing: 3
                                Text { width: parent.width; text: name; color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true; elide: Text.ElideRight }
                                Text { width: parent.width; text: code + " · " + category; color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale); font.family: Theme.dataFont; elide: Text.ElideRight }
                                Text { width: parent.width; text: Number(price).toFixed(price >= 1000 ? 2 : 3) + "  " + (change >= 0 ? "+" : "") + change.toFixed(2) + "%"; color: change >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; elide: Text.ElideRight }
                            }
                            background: Rectangle { color: researchRow.highlighted ? Theme.signalSoft : researchRow.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: researchRow.activeFocus ? Theme.signal : Theme.softLine; Rectangle { visible: researchRow.highlighted; width: 3; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; color: Theme.signal } }
                        }
                    }
                }
            }

            Rectangle {
                id: analysisCanvas
                width: parent.width - objectPool.width - contextPanel.width - 20
                height: parent.height
                color: Theme.surface
                border.width: 1; border.color: Theme.line
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 88; color: Theme.panelBlue
                        border.width: 1; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.margins: 15
                            Column { width: parent.width - researchQuote.width - 18; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { text: root.hasSelection ? root.selectedCode + " / " + root.selectedSector : qsTr("等待选择对象"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                Text { text: root.hasSelection ? root.selectedName : qsTr("选择研究对象"); color: "#FFFFFF"; font.pixelSize: Math.round(20 * Theme.textScale); font.bold: true }
                                Text { text: qsTr("K 线、量能、MACD 与资讯围绕当前标的联动"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale) }
                            }
                            Column { id: researchQuote; width: 138; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { anchors.right: parent.right; text: root.hasSelection ? Number(root.selectedPrice).toFixed(root.selectedPrice >= 1000 ? 2 : 3) : "-"; color: "#FFFFFF"; font.pixelSize: Math.round(23 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                Text { anchors.right: parent.right; text: root.hasSelection ? ((root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%") : "-"; color: root.selectedChange >= 0 ? "#F5A9B4" : "#87DDC5"; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                    KlinePanel {
                        width: parent.width - 20
                        height: Math.max(245, Math.min(338, parent.height - 190))
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.hasSelection
                        instrumentId: root.selectedId
                        titleText: qsTr("主分析画布")
                    }
                    Row {
                        width: parent.width
                        height: Math.max(95, parent.height - 88 - Math.max(245, Math.min(338, parent.height - 190)))
                        spacing: 0
                        Rectangle {
                            width: parent.width * 0.48; height: parent.height
                            color: Theme.surfaceSoft; border.width: 1; border.color: Theme.line
                            Column { anchors.fill: parent; anchors.margins: 12; spacing: 6
                                Text { text: qsTr("量能 / MACD / 资金"); color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                                Text { text: qsTr("量能较过去 5 日均值活跃，MACD 与资金方向仅为本地演示信号。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; width: parent.width; lineHeight: 1.35 }
                                Row { spacing: 16
                                    Column { Text { text: qsTr("主力净流"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) } Text { text: "-0.18 亿"; color: Theme.down; font.pixelSize: Math.round(12 * Theme.textScale); font.family: Theme.dataFont } }
                                    Column { Text { text: qsTr("换手率"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) } Text { text: "1.07%"; color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.family: Theme.dataFont } }
                                }
                            }
                        }
                        Rectangle {
                            width: parent.width * 0.52; height: parent.height
                            color: Theme.surface; border.width: 1; border.color: Theme.line
                            Column { anchors.fill: parent; anchors.margins: 12; spacing: 5
                                Text { text: qsTr("研究资讯"); color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                                Text { text: qsTr("10:22  成交活跃标的增加，关注量价匹配"); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); elide: Text.ElideRight }
                                Text { text: qsTr("09:48  行业研究摘要已更新"); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); elide: Text.ElideRight }
                                Text { text: qsTr("本地演示内容，不构成投资建议"); color: Theme.label; font.pixelSize: Math.round(9 * Theme.textScale); font.family: Theme.dataFont }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: contextPanel
                width: 306; height: parent.height
                color: Theme.surface
                border.width: 1; border.color: Theme.line
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 70; color: Theme.panelBlueDark
                        border.width: 1; border.color: Theme.line
                        Column { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("盘口与关联"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                            Text { text: qsTr("研究上下文"); color: "#FFFFFF"; font.pixelSize: Math.round(16 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("五档、资金与板块"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale) }
                        }
                    }
                    Text { anchors.left: parent.left; anchors.leftMargin: 14; topPadding: 13; text: qsTr("五档行情"); color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                    Repeater {
                        model: ["卖五", "卖四", "卖三", "卖二", "卖一", "买一", "买二", "买三", "买四", "买五"]
                        delegate: Row {
                            width: parent.width - 28; anchors.left: parent.left; anchors.leftMargin: 14; height: 27
                            Text { width: 46; height: parent.height; text: modelData; color: index < 5 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                            Text { width: 82; height: parent.height; text: root.hasSelection ? root.priceAt((index < 5 ? 5 - index : 4 - index) * (root.selectedPrice >= 1000 ? 0.25 : 0.01)) : "-"; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                            Text { width: 65; height: parent.height; text: (1268 + index * 537).toString(); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                        }
                    }
                    Rectangle { width: parent.width - 28; height: 1; anchors.left: parent.left; anchors.leftMargin: 14; color: Theme.line }
                    Column { anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 14; topPadding: 12; spacing: 6
                        Text { text: qsTr("资金与关联板块"); color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                        Text { text: qsTr("所属分类"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) }
                        Text { text: root.hasSelection ? root.selectedSector : "-"; color: Theme.label; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont }
                        Text { text: qsTr("关联：银行 / 高股息 / 宽基指数"); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; width: parent.width }
                        Text { text: qsTr("字段均为包内演示数据"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) }
                    }
                }
            }
        }
    }
}
