import QtQuick 2.12
import QtWebEngine 1.8
import StarKylin 1.0
import "components"

Rectangle {
    id: root
    color: Theme.surface
    property string moduleId: ""
    property string pageState: "loading"
    property string errorSummary: qsTr("指定页面暂时无法打开。")
    property string blockedMessage: ""
    readonly property url entryUrl: moduleId.length > 0 ? appController.moduleEntryUrl(moduleId) : ""
    readonly property bool localEntry: entryUrl.toString().indexOf("qrc:") === 0

    function reloadPage() {
        blockedMessage = ""
        pageState = "loading"
        webView.reload()
    }

    Rectangle {
        id: toolbar
        height: 46
        color: Theme.surface
        border.color: Theme.border
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4
            IconButton { iconName: "arrow-left"; toolTip: qsTr("后退"); enabled: webView.canGoBack; onClicked: webView.goBack() }
            IconButton { iconName: "arrow-right"; toolTip: qsTr("前进"); enabled: webView.canGoForward; onClicked: webView.goForward() }
            IconButton { iconName: "refresh-cw"; toolTip: qsTr("刷新"); onClicked: root.reloadPage() }
            Text { leftPadding: 12; text: root.localEntry ? qsTr("指定业务系统") : qsTr("受控互联网页面"); color: Theme.text900; font.family: Theme.uiFont; font.pixelSize: 14; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 7
            IconGlyph { iconName: "globe-2"; glyphColor: Theme.success; glyphSize: 14; anchors.verticalCenter: parent.verticalCenter }
            Text { text: root.localEntry ? qsTr("演示来源：本地 qrc 页面") : qsTr("演示来源：受控 HTTPS 地址"); color: Theme.text600; font.family: Theme.uiFont; font.pixelSize: 12 }
        }
    }

    Rectangle {
        id: progress
        height: 2
        color: "#E6EDF5"
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: toolbar.bottom
        Rectangle {
            width: parent.width * Math.max(0.04, webView.loadProgress / 100)
            height: parent.height
            color: Theme.primary600
            visible: root.pageState === "loading"
        }
    }

    Item {
        id: pageArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: progress.bottom
        anchors.bottom: parent.bottom
        clip: true

        WebEngineView {
            id: webView
            anchors.fill: parent
            profile: webProfiles.webProfile(root.moduleId)
            url: root.entryUrl
            backgroundColor: Theme.surface
            visible: root.pageState === "loading" || root.pageState === "ready"
            settings.javascriptCanOpenWindows: true
            settings.localContentCanAccessRemoteUrls: false
            settings.pluginsEnabled: false
            settings.fullScreenSupportEnabled: false

            onLoadingChanged: function(loadRequest) {
                if (loadRequest.status === WebEngineView.LoadStartedStatus) {
                    root.pageState = "loading"
                } else if (loadRequest.status === WebEngineView.LoadSucceededStatus) {
                    root.pageState = "ready"
                } else if (loadRequest.status === WebEngineView.LoadFailedStatus) {
                    root.errorSummary = qsTr("无法连接到已授权地址，请检查连接后重新加载。")
                    root.pageState = "error"
                }
            }
            onNavigationRequested: function(request) {
                if (webProfiles.isNavigationAllowed(root.moduleId, request.url)) {
                    request.action = WebEngineView.AcceptRequest
                } else {
                    request.action = WebEngineView.IgnoreRequest
                    root.blockedMessage = qsTr("已阻止打开未授权地址，原业务页面保持不变。")
                }
            }
            onNewViewRequested: function(request) {
                if (webProfiles.isNavigationAllowed(root.moduleId, request.requestedUrl)) {
                    webView.url = request.requestedUrl
                } else {
                    root.blockedMessage = qsTr("已阻止打开未授权地址，原业务页面保持不变。")
                }
            }
            onCertificateError: function(error) {
                error.rejectCertificate()
                root.errorSummary = qsTr("页面证书校验未通过，连接已拒绝。")
                root.pageState = "error"
            }
            onRenderProcessTerminated: function(terminationStatus, exitCode) {
                root.errorSummary = qsTr("页面进程已停止，请重新加载。")
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
            title: qsTr("页面暂时无法打开")
            detail: root.errorSummary
            actionText: qsTr("重新加载")
            tone: Theme.danger
            toneBackground: Theme.dangerSoft
            onActionTriggered: root.reloadPage()
        }

        Rectangle {
            z: 4
            width: Math.min(430, parent.width - 32)
            height: 58
            radius: 5
            color: Theme.surface
            border.color: "#D6B6BA"
            visible: root.blockedMessage.length > 0
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 14

            Rectangle { width: 4; radius: 2; color: Theme.danger; anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom }
            IconGlyph { x: 18; anchors.verticalCenter: parent.verticalCenter; iconName: "triangle-alert"; glyphColor: Theme.danger; glyphSize: 18 }
            Text { x: 50; width: parent.width - 104; anchors.verticalCenter: parent.verticalCenter; text: root.blockedMessage; color: Theme.text700; font.family: Theme.uiFont; font.pixelSize: 12; wrapMode: Text.Wrap }
            IconButton { anchors.right: parent.right; anchors.rightMargin: 5; anchors.verticalCenter: parent.verticalCenter; iconName: "x"; toolTip: qsTr("关闭提示"); onClicked: root.blockedMessage = "" }
        }
    }

    Connections {
        target: webProfiles.businessProfile
        function onDownloadRequested(download) {
            download.cancel()
            root.blockedMessage = qsTr("文件下载已被演示环境阻止。")
        }
    }

}
