import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Rectangle {
    id: root
    property string instrumentId: "hs300"
    color: Theme.surface
    border.color: Theme.line
    Column {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6
        Row {
            spacing: 4
            Repeater { model: ["分时", "日 K", "周 K", "月 K"]
                delegate: Button { id: periodButton; text: modelData; height: 25; checkable: true; checked: chart.period === modelData; onClicked: chart.period = modelData
                    contentItem: Text { text: periodButton.text; color: periodButton.checked ? Theme.primary : Theme.ink; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { radius: 2; color: periodButton.checked ? "#E4F0FC" : Theme.surface; border.width: 1; border.color: periodButton.checked ? Theme.primary : Theme.line }
                }
            }
            Item { width: 8; height: 1 }
            Button {
                id: zoomOut
                text: "-"
                width: 26
                height: 25
                onClicked: chart.zoomOut()
                contentItem: Text { text: zoomOut.text; color: Theme.ink; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { radius: 2; color: zoomOut.hovered ? "#F2F7FB" : Theme.surface; border.width: 1; border.color: Theme.line }
            }
            Button {
                id: zoomIn
                text: "+"
                width: 26
                height: 25
                onClicked: chart.zoomIn()
                contentItem: Text { text: zoomIn.text; color: Theme.ink; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { radius: 2; color: zoomIn.hovered ? "#F2F7FB" : Theme.surface; border.width: 1; border.color: Theme.line }
            }
            Button {
                id: resetButton
                text: qsTr("重置")
                height: 25
                onClicked: chart.resetView()
                contentItem: Text { text: resetButton.text; color: Theme.ink; font.pixelSize: 11; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { radius: 2; color: resetButton.hovered ? "#F2F7FB" : Theme.surface; border.width: 1; border.color: Theme.line }
            }
            Label { text: qsTr("MA5 · 成交量 · MACD"); color: Theme.muted; font.pixelSize: 10; leftPadding: 6; anchors.verticalCenter: parent.verticalCenter }
            Label { text: qsTr("第 %1 根起 · %2 根").arg(chart.visibleStart + 1).arg(chart.visibleCount); color: Theme.muted; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
        }
        KlineChartItem {
            id: chart
            width: parent.width
            height: parent.height - 31
            instrumentId: root.instrumentId
            focus: true
        }
    }
}
