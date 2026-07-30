import QtQuick 2.12
import QtQuick.Controls 2.5
import KylinSky 1.0

Item {
    id: root
    property string moduleId: "network"
    property bool checking: false
    property bool simulateFailure: false
    property int selectedTool: 0
    property string nativeResult: qsTr("选择一个已批准的本机工具后启动。")
    readonly property bool isNetwork: moduleId === "network"
    readonly property var nativeTools: [
        { id: "native-integration", code: qsTr("终"), name: qsTr("终端"), detail: qsTr("在独立系统窗口中打开命令终端。") },
        { id: "native-calculator", code: qsTr("算"), name: qsTr("计算器"), detail: qsTr("调用麒麟系统计算器完成辅助核对。") },
        { id: "native-browser", code: qsTr("览"), name: qsTr("系统浏览器"), detail: qsTr("以系统可信浏览器打开独立会话。") }
    ]

    ListModel {
        id: protocols
        ListElement { name: "HTTP"; endpoint: "批准业务连通性"; status: "等待检查"; detail: "未发起" }
        ListElement { name: "HTTPS"; endpoint: "已批准外部来源"; status: "等待检查"; detail: "未发起" }
        ListElement { name: "SSE"; endpoint: "演示状态通道"; status: "待配置"; detail: "未配置端点" }
        ListElement { name: "WebSocket"; endpoint: "演示事件通道"; status: "待配置"; detail: "未配置端点" }
    }
    Timer {
        id: checkTimer
        interval: 550
        onTriggered: {
            root.checking = false
            for (var i = 0; i < protocols.count; ++i) {
                if (i >= 2) {
                    protocols.setProperty(i, "status", "待配置")
                    protocols.setProperty(i, "detail", "等待服务地址")
                } else if (root.simulateFailure && i === 1) {
                    protocols.setProperty(i, "status", "演示失败")
                    protocols.setProperty(i, "detail", "演示超时，可重试")
                } else {
                    protocols.setProperty(i, "status", "演示可达")
                    protocols.setProperty(i, "detail", (24 + i * 13) + " ms")
                }
            }
        }
    }
    function runCheck(failure) {
        simulateFailure = failure
        checking = true
        for (var i = 0; i < protocols.count; ++i) {
            protocols.setProperty(i, "status", "检查中")
            protocols.setProperty(i, "detail", "等待结果")
        }
        checkTimer.start()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Item {
            anchors.fill: parent
            visible: root.isNetwork

            Row {
                anchors.fill: parent
                spacing: 0
                Column {
                    width: parent.width - checkPanel.width
                    height: parent.height
                    spacing: 0
                    Rectangle {
                        width: parent.width; height: 78; color: Theme.panelBlue
                        border.width: 1; border.color: Theme.line
                        Item { anchors.fill: parent; anchors.margins: 18
                            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                                Text { text: qsTr("网络验证"); color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                                Text { text: qsTr("验证受控网络通道与协议连接状态"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                            }
                            Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: root.checking ? qsTr("检查中") : qsTr("受控网络"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                        }
                    }
                    Grid {
                        width: parent.width; height: 202; columns: 2; spacing: 0
                        Repeater {
                            model: protocols
                            delegate: Rectangle {
                                width: parent.width / 2; height: parent.height / 2
                                color: Theme.surface; border.width: 1; border.color: Theme.softLine
                                Column { anchors.fill: parent; anchors.margins: 16; spacing: 6
                                    Text { text: name; color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                                    Text { text: status; color: status === "演示可达" ? Theme.down : status === "演示失败" ? Theme.up : status === "待配置" ? Theme.gold : Theme.ink; font.pixelSize: Math.round(17 * Theme.textScale); font.bold: true }
                                    Text { text: detail; color: status === "待配置" ? Theme.gold : Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale) }
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width; height: parent.height - 280; color: Theme.surface; border.width: 1; border.color: Theme.line
                        Column { anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 18; spacing: 0
                            Repeater {
                                model: [{k:"DNS 解析",v:qsTr("已批准业务域名"),s:qsTr("通过")},{k:"TLS 握手",v:qsTr("HTTPS 来源校验"),s:qsTr("通过")},{k:qsTr("事件流"),v:qsTr("服务端推送通道"),s:qsTr("待配置")},{k:qsTr("双向通道"),v:qsTr("WebSocket 连接"),s:qsTr("待配置")}]
                                delegate: Rectangle { width: parent.width; height: 56; color: "transparent"; border.width: 0
                                    Rectangle { width: parent.width; height: 1; anchors.bottom: parent.bottom; color: Theme.softLine }
                                    Row { anchors.fill: parent
                                        Text { width: 110; height: parent.height; text: modelData.k; color: Theme.ink; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: true; verticalAlignment: Text.AlignVCenter }
                                        Text { width: parent.width - 180; height: parent.height; text: modelData.v; color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); verticalAlignment: Text.AlignVCenter }
                                        Text { width: 70; height: parent.height; text: modelData.s; color: modelData.s === qsTr("通过") ? Theme.down : Theme.gold; font.pixelSize: Math.round(11 * Theme.textScale); horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter }
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: checkPanel; width: 320; height: parent.height; color: Theme.surface; border.width: 1; border.color: Theme.line
                    Column { anchors.fill: parent; anchors.margins: 18; spacing: 13
                        Text { text: qsTr("连接检查"); color: Theme.ink; font.pixelSize: Math.round(17 * Theme.textScale); font.bold: true }
                        Text { width: parent.width; text: qsTr("检查结果仅描述当前工作台的受控通道状态。业务访问、证书校验和来源规则由正式客户端执行。 "); color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.45 }
                        Button {
                            id: runButton; width: parent.width; height: 40; enabled: !root.checking; text: root.checking ? qsTr("正在检查") : qsTr("重新检查")
                            onClicked: root.runCheck(false)
                            contentItem: Text { text: runButton.text; color: Theme.command; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: runButton.down ? "#2AAEBE" : runButton.hovered ? "#57D6E2" : Theme.signal; border.width: 1; border.color: runButton.activeFocus ? Theme.ink : Theme.signal }
                        }
                        Button {
                            id: failButton; width: parent.width; height: 34; enabled: !root.checking; text: qsTr("模拟失败并重试")
                            onClicked: root.runCheck(true)
                            contentItem: Text { text: failButton.text; color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: failButton.hovered ? Theme.surfaceSoft : "transparent"; border.width: 1; border.color: failButton.activeFocus ? Theme.signal : Theme.line }
                        }
                    }
                }
            }
        }

        Item {
            anchors.fill: parent
            visible: !root.isNetwork
            Column {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    width: parent.width; height: 78; color: Theme.panelBlue
                    border.width: 1; border.color: Theme.line
                        Item { anchors.fill: parent; anchors.margins: 18
                        Column { anchors.verticalCenter: parent.verticalCenter; spacing: 3
                            Text { text: qsTr("本机应用集成"); color: Theme.ink; font.pixelSize: Math.round(19 * Theme.textScale); font.bold: true }
                            Text { text: qsTr("从固定清单启动已批准的麒麟原生应用"); color: Theme.labelMuted; font.pixelSize: Math.round(11 * Theme.textScale) }
                        }
                        Text { anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: qsTr("权限已加载"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                    }
                }
                // Positioner children must not use anchors; the fixed item owns the card row.
                Item {
                    width: parent.width
                    height: 258
                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 14
                        Repeater {
                            model: root.nativeTools
                            delegate: Rectangle {
                                width: (parent.width - 28) / 3
                                height: parent.height
                                color: index === root.selectedTool ? Theme.surfaceSoft : Theme.surface
                                border.width: 1
                                border.color: index === root.selectedTool ? Theme.signal : Theme.line
                                Rectangle {
                                    id: toolIcon
                                    width: 34; height: 34
                                    anchors.left: parent.left; anchors.leftMargin: 20
                                    anchors.top: parent.top; anchors.topMargin: 20
                                    color: Theme.panelBlueDark; border.width: 1; border.color: Theme.line
                                    Text { anchors.centerIn: parent; text: modelData.code; color: Theme.signal; font.pixelSize: Math.round(12 * Theme.textScale); font.bold: true }
                                }
                                Text {
                                    anchors.left: parent.left; anchors.leftMargin: 20
                                    anchors.top: toolIcon.bottom; anchors.topMargin: 13
                                    text: modelData.name; color: Theme.ink; font.pixelSize: Math.round(18 * Theme.textScale); font.bold: true
                                }
                                Text {
                                    anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 20
                                    anchors.top: toolIcon.bottom; anchors.topMargin: 43
                                    text: modelData.detail; color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale)
                                    wrapMode: Text.Wrap; lineHeight: 1.4
                                }
                                Button {
                                    id: nativeLaunch
                                    anchors.left: parent.left; anchors.right: parent.right
                                    anchors.leftMargin: 20; anchors.rightMargin: 20
                                    anchors.bottom: parent.bottom; anchors.bottomMargin: 20
                                    height: 42; text: qsTr("启动应用")
                                    onClicked: { root.selectedTool = index; root.nativeResult = appController.launchNativeModule(modelData.id) }
                                    contentItem: Text { text: nativeLaunch.text; color: Theme.command; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    background: Rectangle { color: nativeLaunch.down ? "#2AAEBE" : nativeLaunch.hovered ? "#57D6E2" : Theme.signal; border.width: 1; border.color: nativeLaunch.activeFocus ? Theme.ink : Theme.signal }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    width: parent.width - 36; height: 86
                    x: 18
                    color: Theme.surface; border.width: 1; border.color: Theme.line
                    Row { anchors.fill: parent; anchors.margins: 16; spacing: 20
                        Column { width: 110; anchors.verticalCenter: parent.verticalCenter; spacing: 4
                            Text { text: qsTr("启动反馈"); color: Theme.ink; font.pixelSize: Math.round(13 * Theme.textScale); font.bold: true }
                            Text { text: root.nativeTools[root.selectedTool].name; color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
                        }
                        Text { width: parent.width - 420; anchors.verticalCenter: parent.verticalCenter; text: root.nativeResult; color: Theme.muted; font.pixelSize: Math.round(11 * Theme.textScale); wrapMode: Text.Wrap; elide: Text.ElideRight }
                        Text { width: 260; anchors.verticalCenter: parent.verticalCenter; text: qsTr("固定路径由 Manifest 和 C++ 层校验；不经 Shell，不传递会话或凭据。 "); color: Theme.muted; font.pixelSize: Math.round(10 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.35 }
                    }
                }
            }
        }
    }
}
