#include "appcontroller.h"
#include "klinechartitem.h"
#include "manifestservice.h"
#include "marketdataservice.h"
#include "nativelauncher.h"
#include "urlpolicy.h"

#include <QFile>
#include <QGuiApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QtTest>
#include <qqml.h>

class AllTests final : public QObject {
    Q_OBJECT

private slots:
    void resources();
    void manifest();
    void urlPolicy();
    void marketData();
    void nativeLauncher();
    void appController();
    void klineChart();
    void qmlComponents();

private:
    static ManifestData demoManifest();
};

ManifestData AllTests::demoManifest()
{
    ManifestData manifest;
    QString error;
    if (!ManifestService::load(QStringLiteral(":/config/manifest.json"), &manifest, &error))
        qFatal("Unable to load test manifest: %s", qPrintable(error));
    return manifest;
}

void AllTests::resources()
{
    const QStringList paths = {
        QStringLiteral(":/qml/Main.qml"), QStringLiteral(":/config/manifest.json"),
        QStringLiteral(":/config/market-fixtures.json"), QStringLiteral(":/web-demo/index.html"),
        QStringLiteral(":/icons/landmark.svg"), QStringLiteral(":/qml/MarketWorkspace.qml"),
        QStringLiteral(":/qml/TrendCanvas.qml"),
        QStringLiteral(":/qml/MarketOverviewWorkspace.qml"), QStringLiteral(":/qml/GlobalWorkspace.qml"),
        QStringLiteral(":/qml/FuturesWorkspace.qml"), QStringLiteral(":/qml/GoldWorkspace.qml"),
        QStringLiteral(":/qml/ResearchWorkspace.qml"), QStringLiteral(":/qml/NativeMarketWorkspace.qml"),
        QStringLiteral(":/qml/WebModulePage.qml"), QStringLiteral(":/qml/ServicePage.qml"),
        QStringLiteral(":/qml/ConfigErrorPage.qml")};
    for (const QString &path : paths)
        QVERIFY2(QFile::exists(path), qPrintable(path));
}

void AllTests::manifest()
{
    const QByteArray valid = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["market","web"]},
      "modules":[
        {"id":"market","type":"market","name":"市场","description":"本地数据","group":"市场观察"},
        {"id":"web","type":"web","name":"业务","description":"受控入口","group":"应用服务","entryUrl":"qrc:/web-demo/index.html","allowedLocalPrefixes":["qrc:/web-demo/"],"allowedNavigationOrigins":[],"allowedResourceOrigins":[]}
      ]
    })json";
    const QByteArray unapproved = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["web"]},
      "modules":[{"id":"web","type":"web","name":"业务","description":"受控入口","group":"应用服务","entryUrl":"https://example.test/","allowedLocalPrefixes":[],"allowedNavigationOrigins":[],"allowedResourceOrigins":[]}]
    })json";
    const QByteArray escalation = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["external"]},
      "modules":[{"id":"external","type":"web","name":"在线网页","description":"批准来源","group":"应用服务","entryUrl":"https://www.baidu.com/","allowedLocalPrefixes":[],"allowedNavigationOrigins":["https://www.baidu.com"],"allowedResourceOrigins":["https://www.baidu.com"],"approvedPages":[{"id":"bilibili","name":"哔哩哔哩","entryUrl":"https://www.bilibili.com/","allowedNavigationOrigins":["https://www.bilibili.com"],"allowedResourceOrigins":["https://www.bilibili.com"]}]}]
    })json";
    const QByteArray overflow = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["native"]},
      "modules":[{"id":"native","type":"native","name":"工具","description":"固定路径","group":"应用服务","program":"/usr/bin/tool","args":["1","2","3","4","5","6"]}]
    })json";
    const QByteArray hiddenNative = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["native"]},
      "modules":[{"id":"native","type":"native","name":"工具","description":"固定路径","group":"原生能力","showInNavigation":false,"program":"/usr/bin/tool","args":[]}]
    })json";

    ManifestData manifest;
    QString error;
    QVERIFY2(ManifestService::parse(valid, &manifest, &error), qPrintable(error));
    QVERIFY(!ManifestService::parse(unapproved, &manifest, &error));
    QVERIFY(error.contains(QStringLiteral("精确授权")));
    QVERIFY(!ManifestService::parse(escalation, &manifest, &error));
    QVERIFY(error.contains(QStringLiteral("未在模块范围内授权")));
    QVERIFY(!ManifestService::parse(overflow, &manifest, &error));
    QVERIFY(error.contains(QStringLiteral("原生启动配置")));
    QVERIFY2(ManifestService::parse(hiddenNative, &manifest, &error), qPrintable(error));
    QVERIFY(!manifest.modules.first().showInNavigation);
}

void AllTests::urlPolicy()
{
    ManifestData manifest;
    ModuleDefinition local;
    local.id = QStringLiteral("local");
    local.type = QStringLiteral("web");
    local.allowedLocalPrefixes = QStringList() << QStringLiteral("qrc:/web-demo/");
    ModuleDefinition remote;
    remote.id = QStringLiteral("remote");
    remote.type = QStringLiteral("web");
    remote.allowedNavigationOrigins = QStringList() << QStringLiteral("https://service.example");
    remote.allowedResourceOrigins = QStringList() << QStringLiteral("https://static.example:8443");
    ApprovedPageDefinition baidu;
    baidu.id = QStringLiteral("baidu");
    baidu.entryUrl = QStringLiteral("https://www.baidu.com/");
    baidu.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.baidu.com");
    baidu.allowedResourceOrigins = baidu.allowedNavigationOrigins;
    ApprovedPageDefinition bilibili;
    bilibili.id = QStringLiteral("bilibili");
    bilibili.entryUrl = QStringLiteral("https://www.bilibili.com/");
    bilibili.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.bilibili.com");
    bilibili.allowedResourceOrigins = bilibili.allowedNavigationOrigins;
    ModuleDefinition external;
    external.id = QStringLiteral("external");
    external.type = QStringLiteral("web");
    external.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.baidu.com") << QStringLiteral("https://www.bilibili.com");
    external.allowedResourceOrigins = external.allowedNavigationOrigins;
    external.approvedPages = {baidu, bilibili};
    manifest.modules = {local, remote, external};

    const UrlPolicy policy(manifest);
    QVERIFY(policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/index.html"))));
    QVERIFY(!policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/../config/manifest.json"))));
    QVERIFY(policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/path"))));
    QVERIFY(!policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("http://service.example/path"))));
    QVERIFY(!policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example:444/path"))));
    QVERIFY(policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://static.example:8443/app.js"))));
    QVERIFY(!policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/app.js"))));
    QVERIFY(policy.navigationAllowed(QStringLiteral("external#baidu"), QUrl(QStringLiteral("https://www.baidu.com/s"))));
    QVERIFY(!policy.navigationAllowed(QStringLiteral("external#baidu"), QUrl(QStringLiteral("https://www.bilibili.com/"))));
    QVERIFY(policy.resourceAllowed(QStringLiteral("external#bilibili"), QUrl(QStringLiteral("https://www.bilibili.com/assets/app.js"))));
    QVERIFY(!policy.resourceAllowed(QStringLiteral("external#bilibili"), QUrl(QStringLiteral("https://www.baidu.com/app.js"))));
}

void AllTests::marketData()
{
    MarketDataService service;
    QVERIFY2(service.ready(), qPrintable(service.error()));
    QVERIFY(service.error().isEmpty());
    QCOMPARE(service.model()->rowCount(), 25);
    const QModelIndex first = service.model()->index(0, 0);
    QCOMPARE(service.model()->data(first, MarketTableModel::IdRole).toString(), QStringLiteral("hs300"));
    QVERIFY(service.model()->data(first, MarketTableModel::PriceRole).toDouble() > 0.0);
    const QVariantMap gold = service.model()->firstForMarket(QStringLiteral("黄金"));
    QCOMPARE(gold.value(QStringLiteral("instrumentId")).toString(), QStringLiteral("gold-bank-boc"));
    QCOMPARE(gold.value(QStringLiteral("code")).toString(), QStringLiteral("BOC-AU"));
    const QVariantMap research = service.model()->firstForMarket(QStringLiteral("国内"), QStringLiteral("pingan"));
    QCOMPARE(research.value(QStringLiteral("instrumentId")).toString(), QStringLiteral("pingan"));
    QCOMPARE(research.value(QStringLiteral("code")).toString(), QStringLiteral("000001"));
    service.reload();
    QVERIFY(service.ready());
    QCOMPARE(service.model()->rowCount(), 25);

    QFile file(QStringLiteral(":/config/market-fixtures.json"));
    QVERIFY(file.open(QIODevice::ReadOnly));
    const QJsonObject series = QJsonDocument::fromJson(file.readAll()).object().value(QStringLiteral("series")).toObject();
    for (const QString &id : {QStringLiteral("hs300"), QStringLiteral("bank-index"), QStringLiteral("au9999")}) {
        const QJsonArray rows = series.value(id).toArray();
        QVERIFY(rows.size() >= 8);
        for (const QJsonValue &value : rows) {
            const QJsonArray row = value.toArray();
            QVERIFY(row.size() == 6);
            QVERIFY(row.at(0).toDouble() > 0.0);
            QVERIFY(row.at(1).toDouble() >= qMax(row.at(0).toDouble(), row.at(3).toDouble()));
            QVERIFY(row.at(2).toDouble() <= qMin(row.at(0).toDouble(), row.at(3).toDouble()));
            QVERIFY(row.at(4).toDouble() >= 0.0);
        }
    }
}

void AllTests::nativeLauncher()
{
    ModuleDefinition wrongType;
    wrongType.type = QStringLiteral("web");
    wrongType.program = QStringLiteral("/usr/bin/true");
    ModuleDefinition relative;
    relative.type = QStringLiteral("native");
    relative.program = QStringLiteral("bin/true");
    ModuleDefinition overflow;
    overflow.type = QStringLiteral("native");
    overflow.program = QStringLiteral("/usr/bin/true");
    overflow.args = QStringList() << QStringLiteral("1") << QStringLiteral("2") << QStringLiteral("3")
                                  << QStringLiteral("4") << QStringLiteral("5") << QStringLiteral("6");
    ModuleDefinition missing;
    missing.type = QStringLiteral("native");
    missing.program = QStringLiteral("/opt/kylin-sky-demo/not-installed");
    QVERIFY(NativeLauncher::launch(wrongType).contains(QStringLiteral("安全检查")));
    QVERIFY(NativeLauncher::launch(relative).contains(QStringLiteral("安全检查")));
    QVERIFY(NativeLauncher::launch(overflow).contains(QStringLiteral("安全检查")));
    QVERIFY(NativeLauncher::launch(missing).contains(QStringLiteral("未找到")));
}

void AllTests::appController()
{
    AppController invalid(demoManifest(), {});
    QVERIFY(!invalid.openModule(QStringLiteral("market")));
    invalid.login(QStringLiteral("operator"), QStringLiteral("wrong"));
    QTRY_VERIFY(!invalid.loginPending());
    QVERIFY(!invalid.authenticated());
    QCOMPARE(invalid.loginError(), QStringLiteral("用户名或密码不正确，请检查后重试。"));

    AppController auditor(demoManifest(), {});
    auditor.login(QStringLiteral("auditor"), QStringLiteral("AuditDemo2026"));
    QTRY_VERIFY(auditor.authenticated());
    QCOMPARE(auditor.moduleModel()->rowCount(), 8);
    QVERIFY(!auditor.openModule(QStringLiteral("external")));
    QVERIFY(auditor.openModule(QStringLiteral("market")));
    QCOMPARE(auditor.tabModel()->rowCount(), 2);
    QVERIFY(auditor.openModule(QStringLiteral("market")));
    QCOMPARE(auditor.tabModel()->rowCount(), 2);
    QVERIFY(auditor.closeTab(QStringLiteral("market")));
    QCOMPARE(auditor.activeModuleId(), QStringLiteral("workbench"));

    AppController operatorController(demoManifest(), {});
    operatorController.login(QStringLiteral("operator"), QStringLiteral("KylinDemo2026"));
    QTRY_VERIFY(operatorController.authenticated());
    QCOMPARE(operatorController.moduleModel()->rowCount(), 11);
    const QVariantList pages = operatorController.approvedPages(QStringLiteral("external"));
    QCOMPARE(pages.size(), 2);
    QCOMPARE(pages.at(0).toMap().value(QStringLiteral("id")).toString(), QStringLiteral("baidu"));
    QCOMPARE(operatorController.moduleEntryUrlForPage(QStringLiteral("external"), QStringLiteral("bilibili")), QUrl(QStringLiteral("https://www.bilibili.com/")));
    QVERIFY(operatorController.moduleEntryUrlForPage(QStringLiteral("external"), QStringLiteral("unlisted")).isEmpty());
    QVERIFY(operatorController.openModule(QStringLiteral("external")));
    operatorController.logout();
    QVERIFY(!operatorController.authenticated());
    QCOMPARE(operatorController.moduleModel()->rowCount(), 0);
    QCOMPARE(operatorController.tabModel()->rowCount(), 1);
    QCOMPARE(operatorController.activeModuleId(), QStringLiteral("workbench"));
}

void AllTests::klineChart()
{
    KlineChartItem chart;
    chart.setInstrumentId(QStringLiteral("hs300"));
    chart.setPeriod(QStringLiteral("日 K"));
    const int dailyCount = chart.visibleCount();
    QVERIFY(dailyCount > 0);
    chart.setPeriod(QStringLiteral("周 K"));
    const int weeklyCount = chart.visibleCount();
    QVERIFY(weeklyCount > 0);
    QVERIFY(weeklyCount < dailyCount);
    chart.setPeriod(QStringLiteral("月 K"));
    const int monthlyCount = chart.visibleCount();
    QVERIFY(monthlyCount > 0);
    QVERIFY(monthlyCount < weeklyCount);
    QCOMPARE(chart.visibleStart(), 0);
    chart.setPeriod(QStringLiteral("日 K"));
    const int beforeZoom = chart.visibleCount();
    chart.zoomIn();
    QVERIFY(chart.visibleCount() <= beforeZoom);
    chart.resetView();
    QVERIFY(chart.visibleStart() >= 0);
}

void AllTests::qmlComponents()
{
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")), "KylinSky", 1, 0, "Theme");
    qmlRegisterType<KlineChartItem>("KylinSky", 1, 0, "KlineChartItem");
    QQmlEngine engine;
    const QList<QUrl> pages = {
        QUrl(QStringLiteral("qrc:/qml/LoginPage.qml")), QUrl(QStringLiteral("qrc:/qml/KlinePanel.qml")),
        QUrl(QStringLiteral("qrc:/qml/TrendCanvas.qml")),
        QUrl(QStringLiteral("qrc:/qml/MarketWorkspace.qml")), QUrl(QStringLiteral("qrc:/qml/MarketOverviewWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/GlobalWorkspace.qml")), QUrl(QStringLiteral("qrc:/qml/FuturesWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/GoldWorkspace.qml")), QUrl(QStringLiteral("qrc:/qml/ResearchWorkspace.qml")),
        QUrl(QStringLiteral("qrc:/qml/NativeMarketWorkspace.qml")), QUrl(QStringLiteral("qrc:/qml/ServicePage.qml")),
        QUrl(QStringLiteral("qrc:/qml/WebModulePage.qml")), QUrl(QStringLiteral("qrc:/qml/AppShell.qml")),
        QUrl(QStringLiteral("qrc:/qml/Main.qml"))};
    for (const QUrl &page : pages) {
        QQmlComponent component(&engine, page);
        QVERIFY2(component.status() == QQmlComponent::Ready, qPrintable(component.errorString()));
    }
}

int main(int argc, char *argv[])
{
    QGuiApplication application(argc, argv);
    AllTests tests;
    return QTest::qExec(&tests, argc, argv);
}

#include "test_all.moc"
