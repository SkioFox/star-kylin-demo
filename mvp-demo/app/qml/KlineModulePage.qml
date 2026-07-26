import QtQuick 2.12
import QtWebEngine 1.8
import StarKylin 1.0
import "components"

Rectangle {
    id: root
    color: Theme.surface
    property string period: "day"
    property string pageState: "loading"
    property string errorSummary: qsTr("行情页面暂时无法打开。")
    readonly property bool moduleOpen: appController.tabModel.count > 1
                                    && appController.tabModel.indexOf("appKline") >= 0
    readonly property string baseEntryUrl: appController.moduleEntryUrl("appKline").toString()
    readonly property url entryUrl: moduleOpen ? baseEntryUrl + "?period=" + period : ""

    function selectPeriod(nextPeriod) {
        period = nextPeriod
    }

    function resetChart() {
        if (pageState === "ready") {
            klineView.reload()
        }
    }

    function reloadPage() {
        pageState = "loading"
        klineView.reload()
    }

    Rectangle {
        id: toolbar
        height: 54
        color: Theme.surface
        border.color: Theme.border
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Column {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            Text { text: qsTr("示例指数"); color: Theme.text900; font.family: Theme.uiFont; font.pixelSize: 14; font.weight: Font.DemiBold }
            Text { text: "DEMO.IDX"; color: Theme.text600; font.family: Theme.dataFont; font.pixelSize: 10 }
        }
        Row {
            x: 136
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            Text { text: "3,219.82"; color: Theme.text900; font.family: Theme.dataFont; font.pixelSize: 20; font.weight: Font.DemiBold }
            Text { visible: root.width >= 720; text: "+6.77  +0.21%"; color: Theme.danger; font.family: Theme.dataFont; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            anchors.right: reset.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            Repeater {
                model: [{ id: "day", label: "日 K" }, { id: "week", label: "周 K" }, { id: "month", label: "月 K" }]
                delegate: StyledButton {
                    width: 64
                    text: modelData.label
                    secondary: root.period !== modelData.id
                    enabled: root.pageState === "ready"
                    onClicked: root.selectPeriod(modelData.id)
                }
            }
        }
        StyledButton {
            id: reset
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("重置视图")
            secondary: true
            enabled: root.pageState === "ready"
            onClicked: root.resetChart()
        }
    }

    Rectangle {
        id: statusLine
        height: 32
        color: "#F8FAFC"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        Row {
            x: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14
            Text { text: qsTr("MOCK 数据"); color: Theme.teal; font.family: Theme.uiFont; font.pixelSize: 11; font.weight: Font.DemiBold }
            Text { text: qsTr("本地数据集"); color: Theme.text600; font.family: Theme.uiFont; font.pixelSize: 11 }
            Text { text: qsTr("更新时间 09:30:00"); color: Theme.text600; font.family: Theme.dataFont; font.pixelSize: 11 }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: statusLine.bottom
        anchors.bottom: parent.bottom

        WebEngineView {
            id: klineView
            anchors.fill: parent
            profile: webProfiles.klineProfile
            url: root.entryUrl
            backgroundColor: Theme.surface
            visible: root.pageState === "loading" || root.pageState === "ready"
            settings.javascriptCanOpenWindows: false
            settings.localContentCanAccessRemoteUrls: false
            settings.pluginsEnabled: false
            settings.fullScreenSupportEnabled: false

            onLoadingChanged: function(loadRequest) {
                if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                    root.pageState = "loading"
                } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    root.pageState = "ready"
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    root.errorSummary = qsTr("无法读取本地行情资源，请重新加载。")
                    root.pageState = "error"
                }
            }
            onNavigationRequested: function(request) {
                if (webProfiles.isNavigationAllowed("appKline", request.url)) {
                    request.action = WebEngineView.AcceptRequest
                } else {
                    request.action = WebEngineView.IgnoreRequest
                }
            }
            onNewViewRequested: function(request) { }
            onCertificateError: function(error) {
                error.rejectCertificate()
                root.errorSummary = qsTr("行情页面证书校验未通过，连接已拒绝。")
                root.pageState = "error"
            }
            onRenderProcessTerminated: function(terminationStatus, exitCode) {
                root.errorSummary = qsTr("行情页面进程已停止，请重新加载。")
                root.pageState = "error"
            }
            onFeaturePermissionRequested: function(securityOrigin, feature) {
                grantFeaturePermission(securityOrigin, feature, false)
            }
            onFullScreenRequested: function(request) { request.reject() }
        }

        ModuleState {
            anchors.fill: parent
            visible: root.pageState === "error"
            iconName: "triangle-alert"
            title: qsTr("行情数据加载失败")
            detail: root.errorSummary
            actionText: qsTr("重新加载数据")
            tone: Theme.danger
            toneBackground: Theme.dangerSoft
            onActionTriggered: root.reloadPage()
        }
    }

}
