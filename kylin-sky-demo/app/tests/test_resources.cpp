#include <QFile>
#include <QtTest>

class ResourcesTest final : public QObject {
    Q_OBJECT

private slots:
    void requiredResourcesExist()
    {
        const QStringList paths = {QStringLiteral(":/qml/Main.qml"),
                                   QStringLiteral(":/config/manifest.json"),
                                   QStringLiteral(":/config/market-fixtures.json"),
                                   QStringLiteral(":/web-demo/index.html"),
                                   QStringLiteral(":/icons/landmark.svg"),
                                   QStringLiteral(":/qml/MarketWorkspace.qml"),
                                   QStringLiteral(":/qml/MarketOverviewWorkspace.qml"),
                                   QStringLiteral(":/qml/GlobalWorkspace.qml"),
                                   QStringLiteral(":/qml/FuturesWorkspace.qml"),
                                   QStringLiteral(":/qml/GoldWorkspace.qml"),
                                   QStringLiteral(":/qml/ResearchWorkspace.qml"),
                                   QStringLiteral(":/qml/NativeMarketWorkspace.qml"),
                                   QStringLiteral(":/qml/WebModulePage.qml"),
                                   QStringLiteral(":/qml/ServicePage.qml"),
                                   QStringLiteral(":/qml/ConfigErrorPage.qml")};
        for (const QString &path : paths) {
            QVERIFY2(QFile::exists(path), qPrintable(path));
        }
    }
};

QTEST_APPLESS_MAIN(ResourcesTest)
#include "test_resources.moc"
