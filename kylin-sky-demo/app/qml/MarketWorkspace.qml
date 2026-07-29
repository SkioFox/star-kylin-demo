import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import KylinSky 1.0

Item {
    id: root
    property string moduleId: "market"
    property string selectedName: ""
    property string selectedCode: ""
    property string selectedCategory: ""
    property string selectedStatus: ""
    property real selectedPrice: 0
    property real selectedChange: 0
    property string selectedAmount: ""

    function titleFor(id) {
        return ({watchlist:"自选", research:"个股研究", market:"市场行情", global:"全球市场", futures:"期货观察", gold:"黄金业务"})[id] || "市场观察"
    }
    function subtitleFor(id) {
        return ({watchlist:"默认关注标的与报价摘要", research:"选中标的后的报价、图表和研究上下文", market:"国内重要指数与行业观察", global:"按主要时区观察全球市场", futures:"商品与能源期货演示数据", gold:"银行黄金演示报价与 Au9999 基准"})[id] || "包内演示数据"
    }
    function includes(marketName) {
        if (moduleId === "global") return marketName === "全球"
        if (moduleId === "futures") return marketName === "期货"
        if (moduleId === "gold") return marketName === "黄金"
        if (moduleId === "market" || moduleId === "research") return marketName === "国内"
        return marketName === "国内" || marketName === "黄金"
    }
    function choose(code, name, category, status, price, change, amount) {
        selectedCode = code; selectedName = name; selectedCategory = category; selectedStatus = status
        selectedPrice = price; selectedChange = change; selectedAmount = amount
    }
    function clearSelection() {
        selectedName = ""
        selectedCode = ""
        selectedCategory = ""
        selectedStatus = ""
        selectedPrice = 0
        selectedChange = 0
        selectedAmount = ""
    }
    function defaultMarket() {
        if (moduleId === "global") return "全球"
        if (moduleId === "futures") return "期货"
        if (moduleId === "gold") return "黄金"
        return "国内"
    }
    function selectDefault() {
        clearSelection()
        if (!marketData.ready) return
        var item = marketData.model.firstForMarket(defaultMarket())
        if (item && item.code) choose(item.code, item.name, item.category, item.status, item.price, item.change, item.amount)
    }
    Component.onCompleted: selectDefault()
    onModuleIdChanged: selectDefault()
    Connections {
        target: marketData
        function onStateChanged() { if (marketData.ready && !root.selectedCode.length) root.selectDefault() }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.surface
                border.color: Theme.line
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 54; color: Theme.surface
                        border.color: Theme.line
                        Column { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Label { text: root.titleFor(root.moduleId); color: Theme.ink; font.pixelSize: 17; font.bold: true }
                            Label { text: root.subtitleFor(root.moduleId); color: Theme.muted; font.pixelSize: 11 }
                        }
                        Label { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: qsTr("包内演示数据 · 每秒受控更新"); color: Theme.muted; font.pixelSize: 11 }
                    }
                    Rectangle {
                        visible: root.moduleId === "gold"
                        Layout.fillWidth: true; Layout.preferredHeight: visible ? 78 : 0
                        color: "#FFFDF8"; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.margins: 10; spacing: 0
                            Repeater { model: [{label:"基准金价", value:"772.60", detail:"Au9999 · +0.68%"},{label:"最低买入价", value:"772.40", detail:"交通银行"},{label:"最高卖出价", value:"778.20", detail:"招商银行"},{label:"报价覆盖", value:"6 / 6", detail:"人民币元/克"}]
                                delegate: Rectangle { width: parent.width / 4; height: parent.height; color: "transparent"; border.color: Theme.line
                                    Column { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                        Label { text: modelData.label; color: Theme.muted; font.pixelSize: 11 }
                                        Label { text: modelData.value; color: Theme.ink; font.pixelSize: 18; font.bold: true }
                                        Label { text: modelData.detail; color: modelData.detail.indexOf("+") >= 0 ? Theme.up : Theme.muted; font.pixelSize: 10 }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 36; color: "#F5F8FB"; border.color: Theme.line
                        Row { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 0
                            Repeater { model: ["代码 / 标的", "最新价", "涨跌幅", "成交额", "分类", "交易状态"]
                                delegate: Label { width: index === 0 ? 190 : index === 1 ? 100 : index === 2 ? 90 : index === 3 ? 100 : index === 4 ? 110 : 90; anchors.verticalCenter: parent.verticalCenter; text: modelData; color: Theme.muted; font.pixelSize: 11; font.bold: true; horizontalAlignment: index === 0 || index === 4 ? Text.AlignLeft : Text.AlignRight }
                            }
                        }
                    }
                    ListView {
                        id: table
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true
                        model: marketData.model
                        delegate: Button {
                            width: table.width
                            height: root.includes(market) ? 46 : 0
                            visible: height > 0
                            highlighted: root.selectedCode === code
                            onClicked: root.choose(code, name, category, status, price, change, amount)
                            contentItem: Row { anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                Column { width: 190; anchors.verticalCenter: parent.verticalCenter; spacing: 1
                                    Label { text: name; color: Theme.ink; font.bold: true; font.pixelSize: 13 }
                                    Label { text: code; color: Theme.muted; font.pixelSize: 10 }
                                }
                                Label { width: 100; anchors.verticalCenter: parent.verticalCenter; text: Number(price).toFixed(price >= 1000 ? 2 : 3); horizontalAlignment: Text.AlignRight; color: Theme.ink; font.family: "Monospace" }
                                Label { width: 90; anchors.verticalCenter: parent.verticalCenter; text: (change >= 0 ? "+" : "") + change.toFixed(2) + "%"; horizontalAlignment: Text.AlignRight; color: change >= 0 ? Theme.up : Theme.down; font.family: "Monospace" }
                                Label { width: 100; anchors.verticalCenter: parent.verticalCenter; text: amount; horizontalAlignment: Text.AlignRight; color: Theme.ink; font.family: "Monospace" }
                                Label { width: 110; anchors.verticalCenter: parent.verticalCenter; text: category; color: Theme.muted; leftPadding: 12 }
                                Label { width: 90; anchors.verticalCenter: parent.verticalCenter; text: status; horizontalAlignment: Text.AlignRight; color: Theme.muted; font.pixelSize: 11 }
                            }
                            background: Rectangle { color: parent.highlighted ? "#E8F2FB" : parent.hovered ? "#F6FAFD" : Theme.surface; border.color: Theme.line }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !marketData.ready
                        color: Theme.surface
                        border.color: Theme.line
                        Column {
                            width: Math.min(360, parent.width - 48)
                            anchors.centerIn: parent
                            spacing: 10
                            Label { text: marketData.error.length ? qsTr("本地数据暂不可用") : qsTr("正在加载本地数据"); color: Theme.ink; font.pixelSize: 17; font.bold: true }
                            Label { width: parent.width; text: marketData.error.length ? marketData.error : qsTr("正在校验包内演示数据。"); color: Theme.muted; wrapMode: Text.Wrap; lineHeight: 1.4 }
                            Button { visible: marketData.error.length; text: qsTr("重新加载"); onClicked: marketData.reload() }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 34; color: Theme.surface; border.color: Theme.line
                        Label { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: root.moduleId === "gold" ? qsTr("报价仅用于查询与对比；实际成交以银行渠道确认结果为准。") : qsTr("行情数据仅为本地演示，不代表真实行情或投资建议。"); color: Theme.muted; font.pixelSize: 11 }
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth: 290; Layout.minimumWidth: 260; Layout.fillHeight: true
                color: Theme.surface; border.color: Theme.line
                Column { anchors.fill: parent; anchors.margins: 14; spacing: 12
                    Label { text: selectedName.length ? selectedCode + " · " + selectedStatus : qsTr("研究上下文"); color: Theme.muted; font.pixelSize: 11 }
                    Label { text: selectedName.length ? selectedName : qsTr("选择一个标的"); color: Theme.ink; font.pixelSize: 19; font.bold: true }
                    Label { visible: selectedName.length; text: Number(selectedPrice).toFixed(selectedPrice >= 1000 ? 2 : 3); color: Theme.ink; font.pixelSize: 25; font.family: "Monospace" }
                    Label { visible: selectedName.length; text: (selectedChange >= 0 ? "+" : "") + selectedChange.toFixed(2) + "%"; color: selectedChange >= 0 ? Theme.up : Theme.down; font.pixelSize: 14; font.bold: true }
                    Rectangle { width: parent.width; height: 1; color: Theme.line }
                    KlinePanel { visible: selectedName.length > 0; width: parent.width; height: 205; instrumentId: selectedCode === "AU9999" ? "au9999" : selectedCode === "399986" ? "bank-index" : "hs300" }
                    Repeater { model: [{label:"所属分类", value:selectedCategory},{label:"成交额", value:selectedAmount},{label:"图表", value:"K 线 · 成交量 · MACD"},{label:"数据边界", value:"仅本地演示数据"}]
                        delegate: Row { width: parent.width; visible: selectedName.length > 0; Label { width: 80; text: modelData.label; color: Theme.muted; font.pixelSize: 11 } Label { width: parent.width - 80; text: modelData.value; color: Theme.ink; font.pixelSize: 11; wrapMode: Text.Wrap } }
                    }
                    Label { visible: !selectedName.length; width: parent.width; text: qsTr("选择左侧行后，在这里查看报价、分类与原生图表上下文。"); color: Theme.muted; wrapMode: Text.Wrap; lineHeight: 1.4 }
                }
            }
        }
    }
}
