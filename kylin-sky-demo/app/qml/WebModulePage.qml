import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebEngine 1.7
import KylinSky 1.0

Item {
    id: root
    property string moduleId: ""
    property string state: "loading"
    property string message: ""
    readonly property url entryUrl: appController.moduleEntryUrl(moduleId)
    function reloadPage() { message = ""; state = "loading"; web.reload() }

    Rectangle { anchors.fill: parent; color: Theme.canvas
        Rectangle { id: toolbar; height: 44; anchors.left: parent.left; anchors.right: parent.right; color: Theme.surface; border.color: Theme.line
            Row { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                Button { text: "‹"; enabled: web.canGoBack; onClicked: web.goBack() }
                Button { text: "›"; enabled: web.canGoForward; onClicked: web.goForward() }
                Button { text: qsTr("刷新"); onClicked: root.reloadPage() }
                Label { text: moduleId === "web" ? qsTr("指定业务系统") : qsTr("在线网页"); color: Theme.ink; font.bold: true; leftPadding: 8; anchors.verticalCenter: parent.verticalCenter }
            }
            Label { anchors.right: parent.right; anchors.rightMargin: 14; anchors.verticalCenter: parent.verticalCenter; text: entryUrl.toString().indexOf("qrc:") === 0 ? qsTr("来源：受控本地业务页") : qsTr("来源：已批准 HTTPS 页面"); color: Theme.muted; font.pixelSize: 11 }
        }
        Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.top: toolbar.bottom; height: 2; color: Theme.line
            Rectangle { width: parent.width * Math.max(.03, web.loadProgress / 100); height: parent.height; color: Theme.primary; visible: root.state === "loading" }
        }
        WebEngineView {
            id: web; anchors.left: parent.left; anchors.right: parent.right; anchors.top: toolbar.bottom; anchors.topMargin: 2; anchors.bottom: parent.bottom
            profile: webProfiles.profile(root.moduleId); url: root.entryUrl; visible: root.state !== "error"
            settings.javascriptCanOpenWindows: false; settings.localContentCanAccessRemoteUrls: false; settings.pluginsEnabled: false; settings.fullScreenSupportEnabled: false
            onLoadingChanged: function(request) { if (request.status === WebEngineView.LoadStartedStatus) root.state = "loading"; else if (request.status === WebEngineView.LoadSucceededStatus) root.state = "ready"; else if (request.status === WebEngineView.LoadFailedStatus) { root.state = "error"; root.message = qsTr("已批准页面暂时无法打开，请检查网络后重新加载。") } }
            onNavigationRequested: function(request) { if (webProfiles.navigationAllowed(root.moduleId, request.url)) request.action = WebEngineView.AcceptRequest; else { request.action = WebEngineView.IgnoreRequest; root.message = qsTr("已阻止打开未授权地址，当前页面未离开受控范围。") } }
            onNewViewRequested: function(request) { request.reject(); root.message = qsTr("新窗口已被演示环境阻止。") }
            onCertificateError: function(error) { error.rejectCertificate(); root.state = "error"; root.message = qsTr("页面证书校验未通过，连接已拒绝。") }
            onFeaturePermissionRequested: function(origin, feature) { grantFeaturePermission(origin, feature, false) }
            onFullScreenRequested: function(request) { request.reject(); root.message = qsTr("全屏请求已被演示环境阻止。") }
        }
        Rectangle { visible: root.state === "error"; anchors.left: parent.left; anchors.right: parent.right; anchors.top: toolbar.bottom; anchors.bottom: parent.bottom; color: Theme.surface
            Column { width: Math.min(440, parent.width - 64); anchors.centerIn: parent; spacing: 12
                Label { text: qsTr("页面暂时无法打开"); color: Theme.ink; font.pixelSize: 21; font.bold: true }
                Label { width: parent.width; text: root.message; wrapMode: Text.Wrap; color: Theme.muted; lineHeight: 1.4 }
                Button { text: qsTr("重新加载"); onClicked: root.reloadPage() }
            }
        }
        Rectangle { visible: root.message.length > 0 && root.state !== "error"; width: Math.min(500, parent.width - 32); height: 44; anchors.horizontalCenter: parent.horizontalCenter; anchors.top: toolbar.bottom; anchors.topMargin: 14; color: "#FFF8F8"; border.color: Theme.up
            Label { anchors.left: parent.left; anchors.leftMargin: 12; anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: root.message; color: Theme.up; font.pixelSize: 12; wrapMode: Text.Wrap }
        }
    }

    Connections {
        target: webProfiles.profile(root.moduleId)
        function onDownloadRequested(download) {
            download.cancel()
            root.message = qsTr("文件下载已被演示环境阻止。")
        }
    }
}
