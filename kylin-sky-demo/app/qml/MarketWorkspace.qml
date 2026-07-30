import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string moduleId: "watchlist"
    property int scanWidth: Math.max(450, Math.round(width * 0.48))
    property string selectedId: ""
    property string selectedCode: ""
    property string selectedName: ""
    property string selectedCategory: ""
    property string selectedStatus: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    property string selectedMetric: ""
    readonly property bool hasSelection: selectedCode.length > 0
    readonly property string instrumentForChart: selectedId.length ? selectedId : "hs300"
    readonly property string activeMarket: moduleId === "global" ? "全球" : moduleId === "futures" ? "期货" : moduleId === "gold" ? "黄金" : "国内"
    readonly property bool isWatchlist: moduleId === "watchlist"
    readonly property bool isGold: moduleId === "gold"
    readonly property bool isFutures: moduleId === "futures"
    readonly property bool isGlobal: moduleId === "global"
    readonly property bool isMarket: moduleId === "market"

    function titleFor() {
        return ({watchlist: "自选", market: "市场行情", global: "全球市场", futures: "期货观察", gold: "黄金业务"})[moduleId] || "市场观察"
    }
    function eyebrowFor() {
        return ({watchlist: "关注标的 / 扫描工作区", market: "国内市场 / 指数比较", global: "全球市场 / 跨时区会话", futures: "期货市场 / 合约矩阵", gold: "黄金报价 / 银行产品"})[moduleId] || "市场观察"
    }
    function subtitleFor() {
        return ({watchlist: "扫描关注标的、资金异动与图表上下文", market: "国内指数、市场宽度和板块节奏", global: "美洲、欧洲、亚太会话与相对走势", futures: "合约、日增仓、期限结构与期市资讯", gold: "积存金买卖报价、点差与 Au9999 基准"})[moduleId] || "本地演示数据"
    }
    function headerLabels() {
        if (isGold) return ["产品 / 银行", "卖出价", "涨跌幅", "点差", "更新时间"]
        if (isFutures) return ["合约 / 交易所", "最新", "涨跌幅", "日增仓", "交易状态"]
        if (isGlobal) return ["指数 / 市场", "最新", "涨跌幅", "会话", "交易状态"]
        if (isMarket) return ["指数 / 分类", "最新", "涨跌幅", "市场宽度", "交易状态"]
        return ["标的 / 代码", "最新价", "涨跌幅", "成交额", "分类"]
    }
    function includes(marketName) {
        if (isWatchlist) return marketName === "国内"
        return marketName === activeMarket
    }
    function summaryModel() {
        if (isGold) return [{k:"Au9999", v:"772.60", d:"+0.68% / 元每克"}, {k:"最低买入", v:"769.40", d:"交通银行"}, {k:"最高卖出", v:"778.20", d:"招商银行"}, {k:"报价覆盖", v:"05 / 05", d:"本地演示数据"}]
        if (isFutures) return [{k:"上涨合约", v:"18", d:"能源与有色偏强"}, {k:"日增仓", v:"+12.4 万", d:"主力合约汇总"}, {k:"夜盘", v:"待开市", d:"交易时间需确认"}, {k:"重点", v:"原油 / 铜", d:"波动率较高"}]
        if (isGlobal) return [{k:"亚太", v:"02 / 04", d:"交易中"}, {k:"欧洲", v:"待开市", d:"夏令时会话"}, {k:"美洲", v:"已收盘", d:"标普 +0.21%"}, {k:"风险偏好", v:"中性", d:"本地演示判断"}]
        if (isMarket) return [{k:"上涨家数", v:"2,186", d:"沪深市场"}, {k:"下跌家数", v:"2,742", d:"跌多涨少"}, {k:"成交额", v:"7,842 亿", d:"较前日 -4.8%"}, {k:"北向相关", v:"-44.6 亿", d:"演示口径"}]
        return [{k:"自选标的", v:"08", d:"关注范围"}, {k:"上涨", v:"05", d:"符号与颜色同步"}, {k:"下跌", v:"03", d:"当前扫描结果"}, {k:"更新时间", v:"10:24", d:"本地受控刷新"}]
    }
    function iconForMetric() {
        if (isGold) return "报价仅用于演示查询与对比"
        if (isFutures) return "日增仓和期限结构均为本地演示"
        if (isGlobal) return "会话状态仅表达演示时间轴"
        if (isMarket) return "市场宽度与资金流为本地演示口径"
        return "选择标的后同步分析区与辅助指标"
    }
    function metricFor(itemAmount, itemStatus) {
        if (isGold) return selectedPrice > 0 ? ("" + (selectedPrice - 3.2).toFixed(2)) : "-"
        if (isFutures) return itemAmount === "-" ? "+1.26 万" : itemAmount
        if (isGlobal) return selectedCategory.indexOf("美洲") >= 0 ? "美洲" : selectedCategory.indexOf("亚太") >= 0 ? "亚太" : "欧洲"
        if (isMarket) return selectedCategory === "宽基指数" ? "涨跌 1,986 / 2,742" : "行业强弱分化"
        return itemAmount
    }
    function choose(instrumentId, code, name, category, status, price, change, amount) {
        selectedId = instrumentId
        selectedCode = code
        selectedName = name
        selectedCategory = category
        selectedStatus = status
        selectedPrice = price
        selectedChange = change
        selectedMetric = amount
    }
    function selectDefault() {
        selectedId = ""
        selectedCode = ""
        if (!marketData.ready) return
        var item = isWatchlist ? marketData.model.firstForMarket("国内") : marketData.model.firstForMarket(activeMarket)
        if (item && item.code) {
            var codeToId = {"000300":"hs300", "399986":"bank-index", "000001":"pingan", "300750":"ningde", "000016":"sse50", "000688":"star50", "SPX":"sp500", "DJI":"dow", "DAX":"dax", "FTSE":"ftse", "N225":"nikkei", "HSI":"hsi", "BRN":"brent", "SC":"crude", "CU0":"copper", "RB":"rebar", "M":"soybeans", "IF":"if-main", "BOC-AU":"gold-bank-boc", "ICBC-AU":"gold-bank-icbc", "CCB-AU":"gold-bank-ccb", "CMB-AU":"gold-bank-cmb", "BOCOM-AU":"gold-bank-bocom", "AU9999":"au9999", "518880":"gold-etf"}
            choose(item.instrumentId || codeToId[item.code] || "hs300", item.code, item.name, item.category, item.status, item.price, item.change, item.amount)
        }
    }
    function setScanWidth(mouseX) {
        var lower = Math.min(460, Math.max(340, width * 0.36))
        var upper = Math.max(lower + 80, width - 330)
        scanWidth = Math.round(Math.max(lower, Math.min(upper, mouseX)))
    }

    Component.onCompleted: selectDefault()
    onModuleIdChanged: selectDefault()
    Connections {
        target: marketData
        function onStateChanged() { if (marketData.ready && !root.hasSelection) root.selectDefault() }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Row {
            anchors.fill: parent
            anchors.margins: Theme.contentPadding
            spacing: 0

            Rectangle {
                id: scanPanel
                width: root.scanWidth
                height: parent.height
                color: Theme.surface
                border.width: 1
                border.color: Theme.line

                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 69
                        color: Theme.panelBlue
                        border.width: 1; border.color: Theme.line
                        Column {
                            anchors.left: parent.left; anchors.leftMargin: 16
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3
                            Text { text: root.eyebrowFor(); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                            Text { text: root.titleFor(); color: "#FFFFFF"; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            Text { text: root.subtitleFor(); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                        }
                        Text { anchors.right: parent.right; anchors.rightMargin: 15; anchors.verticalCenter: parent.verticalCenter; text: qsTr("演示数据 / 10:24"); color: Theme.accentText; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                    }
                    Grid {
                        width: parent.width; columns: 4; spacing: 0
                        Repeater {
                            model: root.summaryModel()
                            delegate: Rectangle {
                                width: parent.width / 4; height: 53
                                color: Theme.surfaceSoft
                                border.width: 1; border.color: Theme.softLine
                                Column { anchors.left: parent.left; anchors.leftMargin: 11; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                    Text { width: parent.width - 18; text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); elide: Text.ElideRight }
                                    Text { text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                    Text { width: parent.width - 18; text: modelData.d; color: modelData.d.indexOf("+") >= 0 ? Theme.up : Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale); elide: Text.ElideRight }
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width; height: 31
                        color: Theme.surfaceSoft
                        border.width: 1; border.color: Theme.line
                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14; anchors.rightMargin: 12
                            Repeater {
                                model: root.headerLabels()
                                delegate: Text {
                                    width: index === 0 ? parent.width * 0.33 : (parent.width * 0.67) / 4
                                    height: parent.height
                                    text: modelData; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); font.bold: true
                                    horizontalAlignment: index === 0 ? Text.AlignLeft : Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
                                }
                            }
                        }
                    }
                    ListView {
                        id: instruments
                        width: parent.width
                        height: parent.height - 69 - 53 - 31 - 30
                        clip: true
                        model: marketData.model
                        delegate: Button {
                            id: instrumentRow
                            width: instruments.width
                            height: root.includes(market) ? Theme.dataRowHeight : 0
                            visible: height > 0
                            highlighted: root.selectedId === instrumentId
                            onClicked: root.choose(instrumentId, code, name, category, status, price, change, amount)
                            Keys.onPressed: function(event) {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) { root.choose(instrumentId, code, name, category, status, price, change, amount); event.accepted = true }
                            }
                            contentItem: Row {
                                anchors.fill: parent
                                anchors.leftMargin: 14; anchors.rightMargin: 12
                                Column { width: parent.width * 0.33; anchors.verticalCenter: parent.verticalCenter; spacing: 2
                                    Text { width: parent.width; text: name; color: Theme.ink; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true; elide: Text.ElideRight }
                                    Text { width: parent.width; text: code + " · " + category; color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale); font.family: Theme.dataFont; elide: Text.ElideRight }
                                }
                                Text { width: (parent.width * 0.67) / 4; height: parent.height; text: Number(price).toFixed(price >= 1000 ? 2 : 3); color: Theme.ink; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: (parent.width * 0.67) / 4; height: parent.height; text: (change >= 0 ? "+" : "") + change.toFixed(2) + "%"; color: change >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                Text { width: (parent.width * 0.67) / 4; height: parent.height; text: root.isGold ? (price - 3.2).toFixed(2) : root.isFutures ? (amount === "-" ? "+1.26 万" : amount) : root.isGlobal ? (category.indexOf("美洲") >= 0 ? "美洲" : category.indexOf("亚太") >= 0 ? "亚太" : "欧洲") : root.isMarket ? (category === "宽基指数" ? "1,986 / 2,742" : "分化") : amount; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { width: (parent.width * 0.67) / 4; height: parent.height; text: root.isGold ? status.replace("演示报价", "10:24") : status; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                            }
                            background: Rectangle {
                                color: instrumentRow.highlighted ? Theme.signalSoft : instrumentRow.hovered ? Theme.surfaceSoft : Theme.surface
                                border.width: 1; border.color: instrumentRow.activeFocus ? Theme.signal : Theme.softLine
                                Rectangle { visible: instrumentRow.highlighted; width: 3; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; color: Theme.signal }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width; height: 30; color: Theme.surface
                        border.width: 1; border.color: Theme.line
                        Text { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: root.iconForMetric(); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    visible: !marketData.ready
                    color: Theme.surface
                    Column { width: Math.min(320, parent.width - 50); anchors.centerIn: parent; spacing: 8
                        Text { text: marketData.error.length ? qsTr("本地数据不可用") : qsTr("正在加载本地数据"); color: Theme.ink; font.pixelSize: Math.round(18 * Theme.textScale); font.bold: true }
                        Text { width: parent.width; text: marketData.error.length ? marketData.error : qsTr("正在校验包内演示数据。 "); color: Theme.muted; wrapMode: Text.Wrap; font.pixelSize: Math.round(12 * Theme.textScale) }
                        Button { visible: marketData.error.length; text: qsTr("重新加载"); onClicked: marketData.reload() }
                    }
                }
            }

            Rectangle {
                id: splitter
                width: 9; height: parent.height
                color: Theme.canvas
                Rectangle { width: 1; anchors.centerIn: parent; height: parent.height - 32; color: Theme.line }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.SizeHorCursor
                    onPositionChanged: {
                        if (pressed) root.setScanWidth(mapToItem(root, mouse.x, mouse.y).x)
                    }
                }
            }

            Rectangle {
                id: detailPanel
                width: parent.width - scanPanel.width - splitter.width
                height: parent.height
                color: Theme.surface
                border.width: 1; border.color: Theme.line
                Column {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 91
                        color: Theme.surface
                        border.width: 1; border.color: Theme.softLine
                        Row {
                            anchors.fill: parent; anchors.margins: 16
                            Column { width: parent.width - quote.width - 20; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                                Text { text: root.hasSelection ? root.selectedCode + " / " + root.selectedStatus : qsTr("等待选择标的"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                Text { text: root.hasSelection ? root.selectedName : qsTr("分析上下文"); color: Theme.ink; font.pixelSize: Math.round(20 * Theme.textScale); font.bold: true }
                                Text { text: root.hasSelection ? (root.selectedCategory + " · " + root.iconForMetric()) : qsTr("从左侧选择一个对象查看当前分析区。 "); color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); elide: Text.ElideRight }
                            }
                            Column { id: quote; width: 142; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { anchors.right: parent.right; text: root.hasSelection ? Number(root.selectedPrice).toFixed(root.selectedPrice >= 1000 ? 2 : 3) : "-"; color: Theme.ink; font.pixelSize: Math.round(25 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                                Text { anchors.right: parent.right; text: root.hasSelection ? ((root.selectedChange >= 0 ? "+" : "") + root.selectedChange.toFixed(2) + "%") : "-"; color: root.selectedChange >= 0 ? Theme.up : Theme.down; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true; font.family: Theme.dataFont }
                            }
                        }
                    }
                    KlinePanel {
                        width: parent.width - 24
                        height: Math.max(230, Math.min(345, parent.height - 230))
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: root.hasSelection
                        instrumentId: root.instrumentForChart
                    }
                    Grid {
                        width: parent.width
                        columns: 2
                        Repeater {
                            model: root.isGold ? [{k:"现货与基准",v:"+1.30 元 / 克"},{k:"报价覆盖",v:"05 家银行"},{k:"产品口径",v:"积存金"},{k:"数据状态",v:"本地演示"}]
                                               : root.isFutures ? [{k:"期限结构",v:"近月升水 0.8%"},{k:"日增仓",v:"+1.26 万"},{k:"关联品种",v:"原油 / 黄金"},{k:"期市要闻",v:"夜盘前观察"}]
                                               : root.isGlobal ? [{k:"相对走势",v:"亚太弱于美洲"},{k:"会话状态",v:"跨时区展示"},{k:"相关指数",v:"DAX / N225"},{k:"数据状态",v:"本地演示"}]
                                               : root.isMarket ? [{k:"市场宽度",v:"1,986 / 2,742"},{k:"热门板块",v:"银行 / 军工"},{k:"主力净流",v:"-446.27 亿"},{k:"量能",v:"较前日 -4.8%"}]
                                               : [{k:"热点板块",v:"银行 / 军工 / 半导体"},{k:"主力净流",v:"-446.27 亿"},{k:"换手率",v:"1.07%"},{k:"量比",v:"0.86"}]
                            delegate: Rectangle {
                                width: parent.width / 2; height: 47
                                color: Theme.surface
                                border.width: 1; border.color: Theme.softLine
                                Column { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                    Text { text: modelData.k; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                                    Text { text: modelData.v; color: Theme.ink; font.pixelSize: Math.round(11 * Theme.textScale); font.family: Theme.dataFont }
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: Math.max(0, parent.height - 91 - Math.max(230, Math.min(345, parent.height - 230)) - 94)
                        color: Theme.surfaceSoft
                        border.width: 1; border.color: Theme.line
                        Text { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: root.isGold ? qsTr("银行报价和基准趋势仅用于演示，不构成交易报价。") : qsTr("行情、图表与研究字段均来自包内演示数据，不构成投资建议。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                    }
                }
            }
        }
    }
}
