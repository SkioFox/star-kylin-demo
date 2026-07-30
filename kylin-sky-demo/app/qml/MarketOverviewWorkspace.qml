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
    readonly property bool ready: selectedId.length > 0
    readonly property var breadthSeries: [41, 45, 43, 56, 51, 62, 54, 60, 67, 63]
    readonly property var breadthBars: [13, 19, 11, 25, 18, 31, 22, 36, 27, 21]

    function choose(instrumentId, code, name, price, change) {
        selectedId = instrumentId
        selectedCode = code
        selectedName = name
        selectedPrice = price
        selectedChange = change
    }
    function selectDefault() {
        if (ready || !marketData.ready) return
        var item = marketData.model.firstForMarket("国内", "sse50")
        if (item && item.code) choose(item.instrumentId, item.code, item.name, item.price, item.change)
    }
    Component.onCompleted: selectDefault()
    Connections { target: marketData; function onStateChanged() { root.selectDefault() } }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Row {
            anchors.fill: parent
            spacing: 0

            Column {
                width: parent.width - marketContext.width
                height: parent.height
                spacing: 0

                Rectangle {
                    width: parent.width; height: 78
                    color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                    Item {
                        anchors.fill: parent; anchors.margins: 18
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("市场行情"); color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("国内主要指数、市场宽度和风格走势"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                        }
                        Button {
                            id: compareButton
                            anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            width: 82; height: Theme.toolHeight - 2; text: qsTr("横向比较")
                            contentItem: Text { text: compareButton.text; color: Theme.accentText; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: compareButton.hovered ? Theme.surfaceSoft : "transparent"; border.width: 1; border.color: compareButton.activeFocus ? Theme.signal : Theme.line }
                        }
                    }
                }

                Row {
                    width: parent.width; height: 82
                    Repeater {
                        model: [
                            { k: qsTr("上证指数"), v: "3,814.20" }, { k: qsTr("深证成指"), v: "13,774.68" },
                            { k: qsTr("上涨家数"), v: "1,936" }, { k: qsTr("市场宽度"), v: "61.0%" },
                            { k: qsTr("成交金额"), v: "8,706 亿" }
                        ]
                        delegate: Rectangle {
                            width: parent.width / 5; height: parent.height
                            color: Theme.surface; border.width: 1; border.color: Theme.softLine
                            Column { anchors.left: parent.left; anchors.leftMargin: 13; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                                Text { text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                                Text { text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(15 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width; height: parent.height - 160
                    Column {
                        anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Text { text: qsTr("市场宽度、指数趋势与量能"); color: Theme.ink; font.pixelSize: Math.round(15 * Theme.textScale); font.bold: true }
                        TrendCanvas {
                            width: parent.width; height: Math.max(150, Math.min(210, parent.height * 0.40))
                            series: [root.breadthSeries]
                            barValues: root.breadthBars
                            fillFirstSeries: true
                            lineColors: [Theme.signal]
                            Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Theme.line }
                        }
                        Text { text: qsTr("热门板块与资金流向"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        Repeater {
                            model: [
                                { n: qsTr("上证指数"), c: "-1.61%", d: qsTr("4,210 亿 · 综合指数") },
                                { n: qsTr("深证成指"), c: "-2.47%", d: qsTr("3,080 亿 · 综合指数") },
                                { n: qsTr("创业板指"), c: "-1.86%", d: qsTr("1,782 亿 · 成长指数") },
                                { n: qsTr("沪深 300"), c: "-0.42%", d: qsTr("626 亿 · 宽基指数") },
                                { n: qsTr("中证 500"), c: "+0.24%", d: qsTr("356 亿 · 中盘指数") }
                            ]
                            delegate: Rectangle {
                            width: parent.width; height: Theme.denseRowHeight; color: Theme.surface
                                border.width: 1; border.color: Theme.softLine
                                Row { anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                    Text { width: parent.width * .40; height: parent.height; text: modelData.n; color: Theme.ink; font.pixelSize: Math.round(11 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width * .18; height: parent.height; text: modelData.c; color: modelData.c.indexOf("-") === 0 ? Theme.down : Theme.up; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width * .42; height: parent.height; text: modelData.d; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: marketContext
                width: 336; height: parent.height
                color: Theme.surface
                border.width: 1; border.color: Theme.line
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 82; color: Theme.panelBlueDark
                        border.width: 1; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.margins: 16
                            Column { width: parent.width - quote.width - 12; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { text: root.selectedCode; color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                Text { text: root.selectedName; color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            }
                            Column { id: quote; width: 120; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { anchors.right: parent.right; text: root.ready ? Number(root.selectedPrice).toFixed(2) : "-"; color: Theme.ink; font.pixelSize: Math.round(23 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                Text { anchors.right: parent.right; text: root.ready ? (root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%" : "-"; color: root.selectedChange >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                    Item { width: parent.width; height: 194
                        TrendCanvas { anchors.fill: parent; anchors.margins: 12; series: [[31, 35, 32, 49, 42, 55, 47, 61, 52]]; barValues: [8, 12, 6, 16, 10, 20, 15, 25, 18]; fillFirstSeries: true; lineColors: [Theme.signal] }
                    }
                    Rectangle { width: parent.width; height: 1; color: Theme.line }
                    Column { width: parent.width; padding: 16; spacing: 13
                        Text { text: qsTr("市场宽度"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        Repeater {
                            model: [{k:qsTr("上涨"),v:qsTr("1,936 家"),d:"61.0%"},{k:qsTr("下跌"),v:qsTr("1,236 家"),d:"39.0%"},{k:qsTr("涨停"),v:qsTr("42 家"),d:qsTr("活跃")}]
                            delegate: Row { width: parent.width; height: 30
                                Text { width: 62; height: parent.height; text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                Text { width: 100; height: parent.height; text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width - 162; height: parent.height; text: modelData.d; color: Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                            }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { width: parent.width; text: qsTr("宽度、量能与板块字段均为包内演示，不构成投资建议。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                    }
                }
                MouseArea {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; height: 82
                    onClicked: {
                        if (!marketData.ready) return
                        var item = marketData.model.firstForMarket("国内", "sse50")
                        if (item && item.code) root.choose(item.instrumentId, item.code, item.name, item.price, item.change)
                    }
                }
            }
        }
    }
}
