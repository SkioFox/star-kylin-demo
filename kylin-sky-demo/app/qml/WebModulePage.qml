import QtQuick 2.12
import QtQuick.Controls 2.5
import QtWebEngine 1.7
import KylinSky 1.0

Item {
    id: root
    property string moduleId: ""
    property string state: "loading"
    property string message: ""
    property var approvedPageList: appController.approvedPages(moduleId)
    property string selectedPageId: ""
    property int reloadCount: 0
    readonly property bool hasApprovedPages: approvedPageList && approvedPageList.length > 0
    readonly property url entryUrl: selectedPageId.length ? appController.moduleEntryUrlForPage(moduleId, selectedPageId) : appController.moduleEntryUrl(moduleId)
    readonly property string moduleTitle: moduleId === "web" ? qsTr("外汇业务") : qsTr("在线网页")
    readonly property string sourceText: entryUrl.toString().indexOf("qrc:") === 0 ? qsTr("包内受控业务演示") : qsTr("已批准 HTTPS 来源")
    readonly property string sourceUrlText: entryUrl.toString().indexOf("qrc:") === 0
                                            ? qsTr("包内离线演示页")
                                            : entryUrl.toString().replace(/\/$/, "")

    function selectPage(pageId) {
        if (selectedPageId === pageId) return
        selectedPageId = pageId
        message = ""
        state = "loading"
    }
    function reloadPage() {
        message = ""
        state = "loading"
        reloadCount += 1
        web.reload()
    }
    function resetPageSelection() {
        selectedPageId = hasApprovedPages ? approvedPageList[0].id : ""
        message = ""
        state = "loading"
    }
    Component.onCompleted: resetPageSelection()
    onModuleIdChanged: resetPageSelection()
    onEntryUrlChanged: {
        message = ""
        state = "loading"
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.canvas

        Rectangle {
            id: toolbar
            height: 64
            anchors.left: parent.left
            anchors.right: parent.right
            color: Theme.panelBlueDark
            border.width: 1
            border.color: Theme.line

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8
                Rectangle {
                    width: 34; height: 34
                    color: Theme.panelBlue; border.width: 1; border.color: Theme.line
                    Text { anchors.centerIn: parent; text: root.moduleId === "web" ? qsTr("汇") : qsTr("网"); color: Theme.signal; font.pixelSize: Math.round(11 * Theme.textScale); font.bold: true }
                }
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text { text: root.moduleTitle; color: Theme.ink; font.pixelSize: Math.round(14 * Theme.textScale); font.bold: true }
                    Text { text: root.sourceText; color: Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale) }
                }
                Row {
                    visible: root.hasApprovedPages
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    Repeater {
                        model: root.approvedPageList
                        delegate: Button {
                            id: sourceButton
                            width: Math.max(70, sourceLabel.implicitWidth + 22); height: Theme.toolHeight - 2
                            text: modelData.name
                            checkable: true
                            checked: root.selectedPageId === modelData.id
                            onClicked: root.selectPage(modelData.id)
                            contentItem: Text { id: sourceLabel; text: sourceButton.text; color: sourceButton.checked ? Theme.ink : Theme.labelMuted; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            background: Rectangle { color: sourceButton.checked ? Theme.signalSoft : sourceButton.hovered ? Theme.panelBlue : "transparent"; border.width: 1; border.color: sourceButton.checked ? Theme.signal : Theme.line }
                        }
                    }
                }
                Text {
                    visible: !root.hasApprovedPages
                    width: Math.max(120, toolbar.width - 460)
                    text: root.sourceUrlText
                    color: Theme.accentText
                    font.pixelSize: Math.round(10 * Theme.textScale)
                    font.family: Theme.dataFont
                    elide: Text.ElideMiddle
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                Button {
                    id: backButton
                    width: 34; height: Theme.toolHeight - 2; text: "‹"; enabled: web.canGoBack
                    onClicked: web.goBack()
                    contentItem: Text { text: backButton.text; color: backButton.enabled ? "#E8F2FA" : "#6E8AA0"; font.pixelSize: Math.round(18 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: backButton.hovered ? Theme.panelBlue : "transparent"; border.width: 1; border.color: backButton.activeFocus ? Theme.signal : Theme.line }
                }
                Button {
                    id: forwardButton
                    width: 34; height: Theme.toolHeight - 2; text: "›"; enabled: web.canGoForward
                    onClicked: web.goForward()
                    contentItem: Text { text: forwardButton.text; color: forwardButton.enabled ? "#E8F2FA" : "#6E8AA0"; font.pixelSize: Math.round(18 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: forwardButton.hovered ? Theme.panelBlue : "transparent"; border.width: 1; border.color: forwardButton.activeFocus ? Theme.signal : Theme.line }
                }
                Button {
                    id: refreshButton
                    width: 74; height: Theme.toolHeight - 2; text: qsTr("刷新")
                    onClicked: root.reloadPage()
                    contentItem: Text { text: refreshButton.text; color: "#E8F2FA"; font.pixelSize: Math.round(10 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: refreshButton.hovered ? Theme.panelBlue : "transparent"; border.width: 1; border.color: refreshButton.activeFocus ? Theme.signal : Theme.line }
                }
            }
        }
        Rectangle {
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: toolbar.bottom
            height: 3; color: Theme.line
            Rectangle { width: parent.width * Math.max(.03, web.loadProgress / 100); height: parent.height; color: Theme.signal; visible: root.state === "loading" }
        }
        WebEngineView {
            id: web
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: toolbar.bottom; anchors.topMargin: 3
            anchors.bottom: parent.bottom
            profile: root.selectedPageId.length ? webProfiles.profileForPage(root.moduleId, root.selectedPageId) : webProfiles.profile(root.moduleId)
            url: root.entryUrl
            // Chromium can defer loading an invisible WebEngineView. The loading/error overlays
            // provide the visual state while the view remains able to progress in the background.
            visible: true
            settings.javascriptCanOpenWindows: false
            settings.localContentCanAccessRemoteUrls: false
            settings.pluginsEnabled: false
            settings.fullScreenSupportEnabled: false
            onLoadingChanged: function(request) {
                if (request.status === WebEngineView.LoadStartedStatus) root.state = "loading"
                else if (request.status === WebEngineView.LoadSucceededStatus) root.state = "ready"
                else if (request.status === WebEngineView.LoadFailedStatus) {
                    root.state = "error"
                    root.message = qsTr("已批准页面暂时无法打开，请检查网络或来源配置后重新加载。")
                }
            }
            onNavigationRequested: function(request) {
                if (root.selectedPageId.length
                        ? webProfiles.navigationAllowedForPage(root.moduleId, root.selectedPageId, request.url)
                        : webProfiles.navigationAllowed(root.moduleId, request.url)) request.action = WebEngineView.AcceptRequest
                else {
                    request.action = WebEngineView.IgnoreRequest
                    root.message = qsTr("已阻止打开未授权地址，当前页面未离开受控范围。")
                }
            }
            onNewViewRequested: function(request) { request.reject(); root.message = qsTr("新窗口已被受控容器阻止。") }
            onCertificateError: function(error) { error.rejectCertificate(); root.state = "error"; root.message = qsTr("页面证书校验未通过，连接已拒绝。") }
            onFeaturePermissionRequested: function(origin, feature) { grantFeaturePermission(origin, feature, false) }
            onFullScreenRequested: function(request) { request.reject(); root.message = qsTr("全屏请求已被受控容器阻止。") }
        }
        Rectangle {
            visible: root.state === "loading"
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: toolbar.bottom; anchors.topMargin: 3
            anchors.bottom: parent.bottom
            color: Theme.canvas
            Column { width: Math.min(390, parent.width - 64); anchors.centerIn: parent; spacing: 11
                Rectangle { width: 34; height: 3; color: Theme.signal }
                Text { text: root.moduleId === "web" ? qsTr("正在加载受控业务演示") : qsTr("正在连接已批准页面"); color: Theme.ink; font.pixelSize: Math.round(20 * Theme.textScale); font.bold: true }
                Text { width: parent.width; text: root.moduleId === "web" ? qsTr("正在打开包内离线业务页面。") : qsTr("仅允许当前批准的 HTTPS 来源；页面资源将按来源策略检查。 "); color: Theme.muted; font.pixelSize: Math.round(12 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                Text { text: root.reloadCount ? qsTr("已请求重新加载") : qsTr("加载中"); color: Theme.label; font.pixelSize: Math.round(10 * Theme.textScale); font.family: Theme.dataFont }
            }
        }
        Rectangle {
            visible: root.state === "error"
            anchors.left: parent.left; anchors.right: parent.right
            anchors.top: toolbar.bottom; anchors.topMargin: 3
            anchors.bottom: parent.bottom
            color: Theme.surface
            Column { width: Math.min(430, parent.width - 64); anchors.centerIn: parent; spacing: 11
                Text { text: qsTr("页面暂时无法打开"); color: Theme.ink; font.pixelSize: Math.round(21 * Theme.textScale); font.bold: true }
                Text { width: parent.width; text: root.message; color: Theme.muted; font.pixelSize: Math.round(12 * Theme.textScale); wrapMode: Text.Wrap; lineHeight: 1.4 }
                Button {
                    id: retryButton
                    width: 106; height: 38; text: qsTr("重新加载")
                    onClicked: root.reloadPage()
                    contentItem: Text { text: retryButton.text; color: "#FFFFFF"; font.pixelSize: Math.round(11 * Theme.textScale); horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: retryButton.hovered ? "#1170A6" : Theme.panelBlue; border.width: 1; border.color: retryButton.activeFocus ? Theme.signal : Theme.panelBlue }
                }
            }
        }
        Rectangle {
            visible: root.message.length > 0 && root.state !== "error"
            width: Math.min(500, parent.width - 32); height: 42
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: toolbar.bottom; anchors.topMargin: 15
            color: "#3B1F32"; border.width: 1; border.color: Theme.up
            Text { anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 12; anchors.verticalCenter: parent.verticalCenter; text: root.message; color: Theme.up; font.pixelSize: Math.round(11 * Theme.textScale); wrapMode: Text.Wrap }
        }
    }

    Connections {
        target: root.selectedPageId.length ? webProfiles.profileForPage(root.moduleId, root.selectedPageId) : webProfiles.profile(root.moduleId)
        function onDownloadRequested(download) {
            download.cancel()
            root.message = qsTr("文件下载已被受控容器阻止。")
        }
    }
}
