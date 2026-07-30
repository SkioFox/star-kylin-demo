import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string selectedId: ""
    property string selectedCode: ""
    property string selectedName: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    property string selectedSpread: ""

    function choose(instrumentId, code, name, price, change, spread) {
        selectedId = instrumentId; selectedCode = code; selectedName = name
        selectedPrice = price; selectedChange = change; selectedSpread = spread
    }
    function selectDefault() {
        if (selectedId.length || !marketData.ready) return
        var item = marketData.model.firstForMarket("黄金", "gold-bank-boc")
        if (item && item.code) choose(item.instrumentId, item.code, item.name, item.price, item.change, item.amount)
    }
    function buyPrice(price, spread) { return (Number(price) - Number(spread)).toFixed(2) }
    Component.onCompleted: selectDefault()
    Connections { target: marketData; function onStateChanged() { root.selectDefault() } }

    Rectangle {
        anchors.fill: parent; color: Theme.canvas
        Row {
            anchors.fill: parent; spacing: 0
            Column {
                width: parent.width - quoteContext.width; height: parent.height; spacing: 0
                Rectangle {
                    width: parent.width; height: 69; color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                    Item { anchors.fill: parent; anchors.margins: 18
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("黄金业务"); color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("银行积存金产品报价、双向点差与基准趋势"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                        }
                        Button {
                            id: unitLabel; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            width: 104; height: Theme.toolHeight - 2; text: qsTr("人民币元 / 克")
                            contentItem: Text { text: unitLabel.text; color: Theme.accentText; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: unitLabel.hovered ? Theme.surfaceSoft : "transparent"; border.width: 1; border.color: unitLabel.activeFocus ? Theme.signal : Theme.line }
                        }
                    }
                }
                Item {
                    width: parent.width; height: parent.height - 69
                    Column { anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Text { text: qsTr("银行产品报价"); color: Theme.ink; font.pixelSize: Math.round(15 * Theme.textScale); font.bold: true }
                        Rectangle {
                            width: parent.width; height: 42; color: Theme.surfaceSoft; border.width: 1; border.color: Theme.line
                            Row { anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                Repeater { model: [qsTr("产品"),qsTr("买入价"),qsTr("卖出价"),qsTr("点差"),qsTr("更新时间")]
                                    delegate: Text { width: index === 0 ? parent.width*.31 : parent.width*.1725; height: parent.height; text: modelData; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter; horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignRight }
                                }
                            }
                        }
                        ListView {
                            id: goldList; width: parent.width; height: 5 * Theme.denseRowHeight; model: marketData.model; clip: true
                            delegate: Button {
                                id: goldRow; width: goldList.width; height: market === "黄金" && category === "银行积存金" ? Theme.denseRowHeight : 0; visible: height > 0
                                highlighted: root.selectedId === instrumentId
                                onClicked: root.choose(instrumentId, code, name, price, change, amount)
                                contentItem: Row { anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                    Text { width: parent.width*.31; height: parent.height; text: name; color: goldRow.highlighted ? Theme.ink : Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: goldRow.highlighted; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                    Text { width: parent.width*.1725; height: parent.height; text: root.buyPrice(price, amount); color: Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width*.1725; height: parent.height; text: Number(price).toFixed(2); color: Theme.up; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width*.1725; height: parent.height; text: amount; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width*.1725; height: parent.height; text: status; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                }
                                background: Rectangle { color: goldRow.highlighted ? Theme.railHover : goldRow.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: goldRow.highlighted ? Theme.signalSoft : Theme.softLine; Rectangle { visible: goldRow.highlighted; width: 3; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; color: Theme.signal } }
                            }
                        }
                        Rectangle {
                            width: parent.width; height: Math.max(170, parent.height - 274); color: Theme.surface; border.width: 1; border.color: Theme.line
                            Column { anchors.fill: parent; anchors.margins: 12; spacing: 8
                                Text { text: qsTr("Au9999 基准走势 · 成交量"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                                TrendCanvas { width: parent.width; height: parent.height - 31; series: [[36,38,42,41,47,52,51,56,60,59,66]]; barValues: [8,10,15,11,20,17,26,18,23,16,29]; fillFirstSeries: true; lineColors: [Theme.gold]
                                    Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Theme.line }
                                }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: quoteContext; width: 360; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                Column { anchors.fill: parent; spacing: 0
                    Rectangle { width: parent.width; height: 82; color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.margins: 16
                            Column { width: parent.width - sellQuote.width - 12; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { text: root.selectedCode + qsTr(" / 报价有效"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                Text { text: root.selectedName; color: Theme.ink; font.pixelSize: Math.round(17 * Theme.textScale); font.bold: true; elide: Text.ElideRight; width: parent.width }
                            }
                            Column { id: sellQuote; width: 112; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { anchors.right: parent.right; text: Number(root.selectedPrice).toFixed(2); color: Theme.ink; font.pixelSize: Math.round(22 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                Text { anchors.right: parent.right; text: (root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%"; color: root.selectedChange >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                            }
                        }
                    }
                    Column { width: parent.width; padding: 16; spacing: 13
                        Text { text: qsTr("现货金与基准价差"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        TrendCanvas { width: parent.width; height: 150; series: [[34,36,45,39,42,48,43,51,47,54]]; barValues: [6,11,15,9,12,18,13,17,10,20]; fillFirstSeries: true; lineColors: [Theme.signal, Theme.gold]
                            Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Theme.line }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { text: qsTr("报价说明"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        Text { width: parent.width; text: qsTr("积存金报价按银行产品口径展示。买入、卖出价格和点差仅为工作台演示数据，不构成交易报价或投资建议。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.45 }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { text: qsTr("关注指标"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        Repeater { model: [{k:"Au9999",v:"772.60"},{k:qsTr("当日振幅"),v:"1.08%"},{k:qsTr("报价家数"),v:"05"}]
                            delegate: Row { width: parent.width; height: 25; Text { width: parent.width*.5; height: parent.height; text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter } Text { width: parent.width*.5; height: parent.height; text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter } }
                        }
                    }
                }
            }
        }
    }
}
