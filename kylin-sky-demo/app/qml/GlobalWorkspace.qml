import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string selectedId: ""
    property string selectedCode: ""
    property string selectedName: ""
    property string selectedCategory: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    readonly property var americas: [43, 45, 44, 48, 52, 51, 55, 59, 58, 61]
    readonly property var europe: [50, 49, 49, 50, 48, 51, 52, 50, 54, 57]
    readonly property var asiaPacific: [34, 36, 37, 38, 42, 43, 41, 45, 47, 46]

    function sessionFor(category) {
        return category.indexOf("亚太") >= 0 ? qsTr("交易中")
             : category.indexOf("欧洲") >= 0 ? qsTr("待开市") : qsTr("已收盘")
    }
    function choose(instrumentId, code, name, category, price, change) {
        selectedId = instrumentId; selectedCode = code; selectedName = name
        selectedCategory = category; selectedPrice = price; selectedChange = change
    }
    function selectDefault() {
        if (selectedId.length || !marketData.ready) return
        var item = marketData.model.firstForMarket("全球", "sp500")
        if (item && item.code) choose(item.instrumentId, item.code, item.name, item.category, item.price, item.change)
    }
    Component.onCompleted: selectDefault()
    Connections { target: marketData; function onStateChanged() { root.selectDefault() } }

    Rectangle {
        anchors.fill: parent; color: Theme.canvas
        Row {
            anchors.fill: parent; spacing: 0
            Column {
                width: parent.width - globalContext.width; height: parent.height; spacing: 0
                Rectangle {
                    width: parent.width; height: 78; color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                    Item { anchors.fill: parent; anchors.margins: 18
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("全球市场"); color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("按亚太、欧洲、美洲交易时段观察主要指数"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                        }
                        Button {
                            id: compareButton; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                            width: 82; height: Theme.toolHeight - 2; text: qsTr("横向比较")
                            contentItem: Text { text: compareButton.text; color: Theme.accentText; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: compareButton.hovered ? Theme.surfaceSoft : "transparent"; border.width: 1; border.color: compareButton.activeFocus ? Theme.signal : Theme.line }
                        }
                    }
                }
                Row {
                    width: parent.width; height: 80
                    Repeater {
                        model: [{k:qsTr("亚太"),v:qsTr("交易中")},{k:qsTr("欧洲"),v:qsTr("待开市")},{k:qsTr("美洲"),v:qsTr("已收盘")},{k:qsTr("时区"),v:"UTC+08"},{k:qsTr("标普 500"),v:"+0.21%"}]
                        delegate: Rectangle { width: parent.width / 5; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.softLine
                            Column { anchors.left: parent.left; anchors.leftMargin: 13; anchors.verticalCenter: parent.verticalCenter; spacing: 6
                                Text { text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                                Text { text: modelData.v; color: modelData.k === qsTr("标普 500") ? Theme.up : Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                }
                Item {
                    width: parent.width; height: parent.height - 158
                    Column { anchors.fill: parent; anchors.margins: 14; spacing: 10
                        Text { text: qsTr("跨时区指数相对走势"); color: Theme.ink; font.pixelSize: Math.round(15 * Theme.textScale); font.bold: true }
                        TrendCanvas { width: parent.width; height: Math.max(140, Math.min(190, parent.height * .36)); series: [root.americas, root.europe, root.asiaPacific]; lineColors: [Theme.signal, Theme.gold, "#4F8BFF"]
                            Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Theme.line }
                        }
                        Row { spacing: 16
                            Repeater { model: [{n:qsTr("美洲"),c:Theme.signal},{n:qsTr("欧洲"),c:Theme.gold},{n:qsTr("亚太"),c:"#4F8BFF"}]
                                delegate: Row { spacing: 6; Rectangle { width: 8; height: 2; color: modelData.c; anchors.verticalCenter: parent.verticalCenter } Text { text: modelData.n; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) } }
                            }
                        }
                        Text { text: qsTr("主要指数比较"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        ListView {
                            id: globalList; width: parent.width; height: Math.max(130, parent.height - 324); clip: true; model: marketData.model
                            delegate: Button {
                                id: globalRow; width: globalList.width; height: market === "全球" ? Theme.denseRowHeight : 0; visible: height > 0
                                highlighted: root.selectedId === instrumentId
                                onClicked: root.choose(instrumentId, code, name, category, price, change)
                                contentItem: Row { anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                    Text { width: parent.width*.35; height: parent.height; text: name; color: globalRow.highlighted ? Theme.ink : Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width*.18; height: parent.height; text: (change >= 0 ? "+" : "") + change.toFixed(2) + "%"; color: change >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; verticalAlignment: Text.AlignVCenter }
                                    Text { width: parent.width*.47; height: parent.height; text: sessionFor(category) + qsTr("时段 · ") + category; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                }
                                background: Rectangle { color: globalRow.highlighted ? Theme.railHover : globalRow.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: globalRow.highlighted ? Theme.signalSoft : Theme.softLine }
                            }
                        }
                    }
                }
            }
            Rectangle {
                id: globalContext; width: 336; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                Column { anchors.fill: parent; spacing: 0
                    Rectangle { width: parent.width; height: 82; color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.margins: 16
                            Column { width: parent.width - globalQuote.width - 12; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { text: root.selectedCode; color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                Text { text: root.selectedName; color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            }
                            Column { id: globalQuote; width: 120; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { anchors.right: parent.right; text: Number(root.selectedPrice).toFixed(2); color: Theme.ink; font.pixelSize: Math.round(23 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                Text { anchors.right: parent.right; text: (root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%"; color: root.selectedChange >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(10 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                    Item { width: parent.width; height: 194
                        TrendCanvas { anchors.fill: parent; anchors.margins: 12; series: [[36, 41, 40, 52, 46, 49, 58, 51, 60]]; barValues: [7, 11, 8, 17, 12, 10, 18, 13, 20]; fillFirstSeries: true; lineColors: [Theme.signal] }
                    }
                    Rectangle { width: parent.width; height: 1; color: Theme.line }
                    Column { width: parent.width; padding: 16; spacing: 13
                        Text { text: qsTr("全球会话状态"); color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                        Repeater {
                            model: [{k:qsTr("亚太"),v:qsTr("东京 / 香港"),d:qsTr("交易中")},{k:qsTr("欧洲"),v:qsTr("伦敦 / 法兰克福"),d:qsTr("待开市")},{k:qsTr("美洲"),v:qsTr("纽约"),d:qsTr("已收盘")}]
                            delegate: Row { width: parent.width; height: 30
                                Text { width: 46; height: parent.height; text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                Text { width: 136; height: parent.height; text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                Text { width: parent.width - 182; height: parent.height; text: modelData.d; color: modelData.d === qsTr("交易中") ? Theme.down : Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                            }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { width: parent.width; text: qsTr("时区、会话和相对走势均为包内演示。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                    }
                }
            }
        }
    }
}
