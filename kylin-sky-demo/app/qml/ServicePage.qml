import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string moduleId: "network"
    property bool checking: false
    property bool simulateFailure: false
    property string nativeResult: "等待本机路径检测。"
    ListModel { id: protocols
        ListElement { name: "HTTP"; endpoint: "批准业务连通性"; status: "等待检查"; detail: "未发起" }
        ListElement { name: "HTTPS"; endpoint: "已批准外部来源"; status: "等待检查"; detail: "未发起" }
        ListElement { name: "SSE"; endpoint: "演示状态通道"; status: "等待检查"; detail: "未发起" }
        ListElement { name: "WebSocket"; endpoint: "演示事件通道"; status: "等待检查"; detail: "未发起" }
    }
    Timer { id: checkTimer; interval: 550; onTriggered: {
        root.checking = false
        for (var i = 0; i < protocols.count; ++i) {
            if (i === 2) { protocols.setProperty(i, "status", "待配置"); protocols.setProperty(i, "detail", "未配置真实端点") }
            else if (root.simulateFailure && i === 3) { protocols.setProperty(i, "status", "演示失败"); protocols.setProperty(i, "detail", "演示超时，可重试") }
            else { protocols.setProperty(i, "status", "演示可达"); protocols.setProperty(i, "detail", (24 + i * 13) + " ms") }
        }
    } }
    function runCheck(failure) {
        simulateFailure = failure
        checking = true
        for (var i = 0; i < protocols.count; ++i) { protocols.setProperty(i, "status", "检查中"); protocols.setProperty(i, "detail", "等待结果") }
        checkTimer.start()
    }
    Rectangle { anchors.fill: parent; color: Theme.canvas
        Column { anchors.fill: parent; anchors.margins: 18; spacing: 14
            Label { text: moduleId === "network" ? qsTr("网络验证") : qsTr("原生行情中心"); color: Theme.ink; font.pixelSize: 20; font.bold: true }
            Label { text: moduleId === "network" ? qsTr("演示状态不包含 Cookie、请求正文或敏感头信息。") : qsTr("仅能启动 Manifest 批准的固定本机路径，不传递门户凭据。 "); color: Theme.muted }
            Row { visible: moduleId === "network"; spacing: 8
                Button { text: checking ? qsTr("正在检查") : qsTr("发起检查"); enabled: !checking; onClicked: runCheck(false) }
                Button { text: qsTr("模拟失败并重试"); enabled: !checking; onClicked: runCheck(true) }
            }
            Button { visible: moduleId !== "network"; text: qsTr("启动已批准工具"); onClicked: nativeResult = appController.launchNativeModule(moduleId) }
            Label { visible: moduleId !== "network"; text: nativeResult; color: Theme.muted; wrapMode: Text.Wrap }
            Repeater { visible: moduleId === "network"; model: protocols
                delegate: Rectangle { width: parent.width; height: 68; color: Theme.surface; border.color: Theme.line
                    Row { anchors.fill: parent; anchors.margins: 13; spacing: 28
                        Label { width: 100; text: name; color: Theme.ink; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                        Label { width: 230; text: endpoint; color: Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                        Label { width: 110; text: status; color: status === "演示可达" ? Theme.down : status === "演示失败" ? Theme.up : status === "待配置" ? Theme.gold : Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: detail; color: Theme.muted; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
    }
}
