#include <QFile>
#include <QtTest>

class ResourcesTest final : public QObject {
    Q_OBJECT

private slots:
    void requiredResourcesExist()
    {
        const QStringList paths = {QStringLiteral(":/config/manifest.json"),
                                   QStringLiteral(":/qml/Main.qml"),
                                   QStringLiteral(":/qml/Theme.qml"),
                                   QStringLiteral(":/web-demo/index.html"),
                                   QStringLiteral(":/web-kline/index.html"),
                                   QStringLiteral(":/web-kline/echarts.min.js"),
                                   QStringLiteral(":/web-kline/mock-market.json"),
                                   QStringLiteral(":/web-kline/mock-market.js"),
                                   QStringLiteral(":/icons/landmark.svg")};
        for (const QString &path : paths) {
            QVERIFY2(QFile::exists(path), qPrintable(path));
        }
    }

    void webPagesUseQt512CompatibleImport()
    {
        const QStringList paths = {QStringLiteral(":/qml/WebModulePage.qml"),
                                   QStringLiteral(":/qml/KlineModulePage.qml")};
        for (const QString &path : paths) {
            QFile file(path);
            QVERIFY2(file.open(QIODevice::ReadOnly | QIODevice::Text), qPrintable(path));
            const QString content = QString::fromUtf8(file.readAll());
            QVERIFY2(content.contains(QStringLiteral("import QtWebEngine 1.8")),
                     qPrintable(path));
        }
    }
};

QTEST_APPLESS_MAIN(ResourcesTest)
#include "test_resources.moc"
