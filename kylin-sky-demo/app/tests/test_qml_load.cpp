#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QDebug>
#include <QList>
#include <qqml.h>

#include "klinechartitem.h"

int main(int argc, char *argv[])
{
    QGuiApplication application(argc, argv);
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")), "KylinSky", 1, 0,
                             "Theme");
    qmlRegisterType<KlineChartItem>("KylinSky", 1, 0, "KlineChartItem");

    QQmlEngine engine;
    const QList<QUrl> pages = {
        QUrl(QStringLiteral("qrc:/qml/LoginPage.qml")),
        QUrl(QStringLiteral("qrc:/qml/KlinePanel.qml")),
        QUrl(QStringLiteral("qrc:/qml/TrendCanvas.qml")),
        QUrl(QStringLiteral("qrc:/qml/MarketWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/MarketOverviewWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/GlobalWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/FuturesWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/GoldWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/ResearchWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/NativeMarketWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/ServicePage.qml")),
        QUrl(QStringLiteral("qrc:/qml/WebModulePage.qml")),
        QUrl(QStringLiteral("qrc:/qml/AppShell.qml")),
        QUrl(QStringLiteral("qrc:/qml/Main.qml"))
    };
    for (const QUrl &page : pages) {
        QQmlComponent component(&engine, page);
        if (component.status() == QQmlComponent::Ready) continue;
        qCritical().noquote() << page.toString() << component.errorString();
        return 1;
    }
    return 0;
}
