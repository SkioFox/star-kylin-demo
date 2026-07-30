import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Rectangle {
    id: root
    property string instrumentId: "hs300"
    property string titleText: qsTr("原生走势与指标")
    color: Theme.surface
    border.width: 1
    border.color: Theme.line

    Column {
        anchors.fill: parent
        anchors.margins: 9
        spacing: 6

        Row {
            width: parent.width
            height: Theme.toolHeight
            spacing: 4
            Text { visible: root.width >= 500; width: visible ? 82 : 0; text: root.titleText; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
            Repeater {
                model: ["分时", "日 K", "周 K", "月 K"]
                delegate: Button {
                    id: periodButton
                    text: modelData
                    width: root.width < 480 ? (modelData === "分时" ? 32 : 34) : (modelData === "分时" ? 37 : 39)
                    height: Theme.toolHeight - 2
                    checkable: true
                    checked: chart.period === modelData
                    onClicked: chart.period = modelData
                    contentItem: Text { text: periodButton.text; color: periodButton.checked ? Theme.command : Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: periodButton.checked ? Theme.signal : periodButton.hovered ? Theme.surfaceSoft : "transparent"; border.width: 1; border.color: periodButton.checked ? Theme.signal : "transparent" }
                }
            }
            Item { width: root.width < 480 ? 0 : 4; height: 1 }
            Button {
                id: zoomOut
                text: "−"
                width: root.width < 480 ? 24 : 30; height: Theme.toolHeight - 2
                onClicked: chart.zoomOut()
                contentItem: Text { text: zoomOut.text; color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: zoomOut.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: zoomOut.activeFocus ? Theme.signal : Theme.line }
            }
            Button {
                id: zoomIn
                text: "+"
                width: root.width < 480 ? 24 : 30; height: Theme.toolHeight - 2
                onClicked: chart.zoomIn()
                contentItem: Text { text: zoomIn.text; color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: zoomIn.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: zoomIn.activeFocus ? Theme.signal : Theme.line }
            }
            Button {
                id: resetButton
                text: qsTr("重置")
                width: root.width < 480 ? 38 : 52; height: Theme.toolHeight - 2
                onClicked: chart.resetView()
                contentItem: Text { text: resetButton.text; color: Theme.ink; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: resetButton.hovered ? Theme.surfaceSoft : Theme.surface; border.width: 1; border.color: resetButton.activeFocus ? Theme.signal : Theme.line }
            }
            Text { visible: root.width >= 600; width: visible ? Math.max(72, parent.width - 430) : 0; text: qsTr("MA5 · 成交量 · MACD"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale); elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
            Text { visible: root.width >= 600; width: visible ? 88 : 0; text: qsTr("%1 / %2 根").arg(chart.visibleStart + 1).arg(chart.visibleCount); color: Theme.label; font.pixelSize: Math.round(9 * Theme.textScale); font.family: Theme.dataFont; horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
        }

        Item {
            width: parent.width
            height: parent.height - Theme.toolHeight - 6
            clip: true
            KlineChartItem {
                id: chart
                anchors.fill: parent
                instrumentId: root.instrumentId
                focus: true
            }
            Text { anchors.left: parent.left; anchors.leftMargin: 6; anchors.top: parent.top; anchors.topMargin: 5; text: qsTr("价格"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) }
            Text { anchors.left: parent.left; anchors.leftMargin: 6; anchors.bottom: parent.bottom; anchors.bottomMargin: 3; text: qsTr("MACD"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) }
            Text { anchors.right: parent.right; anchors.rightMargin: 5; anchors.bottom: parent.bottom; anchors.bottomMargin: 3; text: qsTr("拖拽平移 / 滚轮缩放"); color: Theme.muted; font.pixelSize: Math.round(9 * Theme.textScale) }
        }
    }
}
