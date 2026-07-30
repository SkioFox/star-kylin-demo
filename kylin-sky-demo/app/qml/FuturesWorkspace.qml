import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string selectedId: ""
    property string selectedName: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    readonly property var boards: [
        { title: qsTr("上期所"), rows: [{n:qsTr("沪铜主力"),p:"78,620",c:"+0.48%",o:"+2,240"},{n:qsTr("沪金主连"),p:"772.60",c:"+0.68%",o:"+1,318"}] },
        { title: qsTr("郑商所"), rows: [{n:qsTr("苹果主连"),p:"7,765",c:"+1.38%",o:"+8,223"},{n:qsTr("玻璃主连"),p:"910",c:"+1.11%",o:"-1.83 万"},{n:qsTr("尿素主连"),p:"1,758",c:"+0.51%",o:"-1,174"}] },
        { title: qsTr("大商所"), rows: [{n:qsTr("螺纹主连"),p:"3,574",c:"-0.22%",o:"-1,004"},{n:qsTr("豆粕主连"),p:"3,204",c:"+0.47%",o:"-3,500"},{n:qsTr("原油主连"),p:"618.4",c:"+0.81%",o:"+822"}] },
        { title: qsTr("能源化工"), rows: [{n:qsTr("原油主连"),p:"618.4",c:"+0.81%",o:"+822"},{n:qsTr("燃油主连"),p:"3,152",c:"-0.34%",o:"-1,122"}] },
        { title: qsTr("金融期货"), rows: [{n:qsTr("十年国债"),p:"109.290",c:"+0.07%",o:"-516"},{n:qsTr("沪深 300"),p:"3,821.4",c:"-0.42%",o:"+1,216"}] },
        { title: qsTr("外盘期货"), rows: [{n:qsTr("纽约黄金"),p:"2,392.2",c:"+0.34%",o:"-902"},{n:qsTr("纽约原油"),p:"78.24",c:"+0.61%",o:"+1,188"}] }
    ]

    function choose(instrumentId, name, price, change) {
        selectedId = instrumentId; selectedName = name; selectedPrice = price; selectedChange = change
    }
    function selectDefault() {
        if (selectedId.length || !marketData.ready) return
        var item = marketData.model.firstForMarket("期货", "copper")
        if (item && item.code) choose(item.instrumentId, item.name, item.price, item.change)
    }
    Component.onCompleted: selectDefault()
    Connections { target: marketData; function onStateChanged() { root.selectDefault() } }

    Rectangle {
        anchors.fill: parent; color: Theme.canvas
        Column {
            anchors.fill: parent; anchors.margins: Theme.contentPadding; spacing: 10
            Row {
                width: parent.width; height: Theme.toolHeight
                spacing: 4
                Repeater {
                    model: [qsTr("综合屏"), qsTr("期货"), qsTr("期权"), qsTr("热点商品")]
                    delegate: Button {
                        id: topTab; width: 76; height: Theme.toolHeight - 2; text: modelData; checkable: true; checked: index === 0
                        contentItem: Text { text: topTab.text; color: topTab.checked ? Theme.command : Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: topTab.checked ? Theme.signal : topTab.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: topTab.checked ? Theme.signal : Theme.line }
                    }
                }
                Text { width: parent.width - 288; text: qsTr("行情状态：6 个交易所 / 品类分组已载入"); color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
            }
            Grid {
                id: futuresMatrix
                width: parent.width; height: Math.max(280, parent.height - 207); columns: 3; rows: 2; spacing: 8
                Repeater {
                    model: root.boards
                    delegate: Rectangle {
                        width: (parent.width - 16) / 3; height: (parent.height - 8) / 2; color: Theme.surface; border.width: 1; border.color: Theme.line
                        Column { anchors.fill: parent; spacing: 0
                        Rectangle { width: parent.width; height: 44; color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                                Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: modelData.title; color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true }
                            }
                            Repeater {
                                model: modelData.rows
                                delegate: Button {
                                    id: contractRow; width: parent.width; height: Theme.denseRowHeight; text: modelData.n
                                    onClicked: root.choose("copper", modelData.n, Number(modelData.p.replace(",", "")), Number(modelData.c.replace("%", "")))
                                    contentItem: Row { anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                                        Text { width: parent.width*.36; height: parent.height; text: modelData.n; color: contractRow.hovered ? Theme.ink : Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                        Text { width: parent.width*.23; height: parent.height; text: modelData.p; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                        Text { width: parent.width*.20; height: parent.height; text: modelData.c; color: modelData.c.indexOf("-") === 0 ? Theme.down : Theme.up; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                        Text { width: parent.width*.21; height: parent.height; text: modelData.o; color: modelData.o.indexOf("-") === 0 ? Theme.down : Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                    }
                                    background: Rectangle { color: contractRow.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: Theme.softLine }
                                }
                            }
                        }
                    }
                }
            }
            Row {
                width: parent.width; height: Math.max(130, parent.height - 39 - futuresMatrix.height - 18); spacing: 8
                Rectangle {
                    width: parent.width*.33; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                    Column { anchors.fill: parent; anchors.margins: 12; spacing: 8
                        Text { text: qsTr("期市要闻"); color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true }
                        Repeater { model: ["库存数据更新，原油波动加大", "黑色系夜盘交易安排", "有色金属现货升贴水跟踪", "农产品天气扰动持续"]
                            delegate: Row { width: parent.width; height: 23; spacing: 8; Text { height: parent.height; text: qsTr("资讯"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter } Text { width: parent.width-70; height: parent.height; text: modelData; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter } }
                        }
                    }
                }
                Rectangle {
                    width: parent.width*.43; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                    Column { anchors.fill: parent; anchors.margins: 12; spacing: 7
                        Text { text: root.selectedName.length ? root.selectedName + qsTr(" · 期限结构与量能") : qsTr("沪铜主力 · 期限结构与量能"); color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true }
                        TrendCanvas { width: parent.width; height: parent.height - 34; series: [[35,39,43,50,47,56,53,61]]; barValues: [8,16,24,35,31,45,39,48]; lineColors: [Theme.signal, Theme.up]; fillFirstSeries: false
                            Rectangle { anchors.fill: parent; color: "transparent"; border.width: 1; border.color: Theme.line }
                        }
                    }
                }
                Rectangle {
                    width: parent.width*.24 - 16; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                    Column { anchors.fill: parent; anchors.margins: 12; spacing: 9
                        Text { text: qsTr("关联品种"); color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true }
                        Repeater { model: [{n:qsTr("沪铝主力"),c:"+0.22%"},{n:qsTr("沪锌主力"),c:"-0.18%"},{n:qsTr("国际铜"),c:"+0.31%"}]
                            delegate: Row { width: parent.width; height: 23; Text { width: parent.width*.58; height: parent.height; text: modelData.n; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter } Text { width: parent.width*.42; height: parent.height; text: modelData.c; color: modelData.c.indexOf("-") === 0 ? Theme.down : Theme.up; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter } }
                        }
                        Rectangle { width: parent.width; height: 1; color: Theme.line }
                        Text { width: parent.width; text: qsTr("合约、持仓和资讯均为本地演示数据。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                    }
                }
            }
        }
    }
}
