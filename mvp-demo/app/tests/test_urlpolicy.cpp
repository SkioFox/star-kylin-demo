#include "urlpolicy.h"

#include <QtTest>

namespace {

ManifestData policyManifest()
{
    ManifestData manifest;

    ModuleDefinition local;
    local.id = QStringLiteral("local");
    local.type = QStringLiteral("web");
    local.allowedLocalPrefixes = QStringList{QStringLiteral("qrc:/web-demo/")};

    ModuleDefinition remote;
    remote.id = QStringLiteral("remote");
    remote.type = QStringLiteral("web");
    remote.allowedNavigationOrigins =
        QStringList{QStringLiteral("https://service.example")};
    remote.allowedResourceOrigins =
        QStringList{QStringLiteral("https://static.example:8443")};

    ModuleDefinition kline;
    kline.id = QStringLiteral("kline");
    kline.type = QStringLiteral("kline");
    kline.entryUrl = QStringLiteral("qrc:/web-kline/index.html");

    manifest.modules = {local, remote, kline};
    return manifest;
}

} // namespace

class UrlPolicyTest final : public QObject {
    Q_OBJECT

private slots:
    void acceptsOnlyTheConfiguredQrcPrefix()
    {
        const UrlPolicy policy(policyManifest());
        QVERIFY(policy.isNavigationAllowed(
            QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/index.html"))));
        QVERIFY(policy.isResourceAllowed(
            QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/styles.css"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/../config/manifest.json"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/%2e%2e/config/manifest.json"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo-evil/index.html"))));
    }

    void comparesEffectiveHttpsOriginsExactly()
    {
        const UrlPolicy policy(policyManifest());
        QVERIFY(policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/path"))));
        QVERIFY(policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example:443/next"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("http://service.example/path"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example:444/path"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example.evil/path"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://user@service.example/path"))));
    }

    void keepsNavigationAndResourceOriginsSeparate()
    {
        const UrlPolicy policy(policyManifest());
        QVERIFY(!policy.isResourceAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/app.js"))));
        QVERIFY(policy.isResourceAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://static.example:8443/app.js"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("remote"), QUrl(QStringLiteral("https://static.example:8443/page"))));
    }

    void restrictsKlineToItsOwnQrcDirectory()
    {
        const UrlPolicy policy(policyManifest());
        QVERIFY(policy.isNavigationAllowed(
            QStringLiteral("kline"), QUrl(QStringLiteral("qrc:/web-kline/index.html"))));
        QVERIFY(policy.isResourceAllowed(
            QStringLiteral("kline"), QUrl(QStringLiteral("qrc:/web-kline/echarts.min.js"))));
        QVERIFY(!policy.isResourceAllowed(
            QStringLiteral("kline"), QUrl(QStringLiteral("https://cdn.example/echarts.js"))));
        QVERIFY(!policy.isNavigationAllowed(
            QStringLiteral("kline"), QUrl(QStringLiteral("qrc:/web-demo/index.html"))));
    }
};

QTEST_APPLESS_MAIN(UrlPolicyTest)
#include "test_urlpolicy.moc"
