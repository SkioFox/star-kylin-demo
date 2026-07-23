#include "manifestservice.h"

#include <QtTest>

namespace {

QByteArray validManifest()
{
    return R"json({
      "schemaVersion": 1,
      "users": {
        "demoA": {"password":"demo-only","displayName":"演示用户 A","role":"roleA"}
      },
      "roles": {"roleA":["appWeb","appKline"]},
      "modules": [
        {
          "id":"appWeb","type":"web","name":"Web 业务","description":"指定业务页面",
          "icon":"globe-2","status":"授权来源可用","accent":"#0B5CAD","tint":"#EAF2FC",
          "entryUrl":"qrc:/web-demo/index.html","allowedLocalPrefixes":["qrc:/web-demo/"],
          "allowedNavigationOrigins":[],"allowedResourceOrigins":[]
        },
        {
          "id":"appKline","type":"kline","name":"行情中心","description":"本地 Mock 行情",
          "icon":"chart-candlestick","status":"本地数据可用","accent":"#1C7F8F","tint":"#E4F2F4",
          "entryUrl":"qrc:/web-kline/index.html"
        }
      ]
    })json";
}

} // namespace

class ManifestTest final : public QObject {
    Q_OBJECT

private slots:
    void acceptsValidManifest()
    {
        ManifestData manifest;
        QString error;
        QVERIFY2(ManifestService::parse(validManifest(), &manifest, &error), qPrintable(error));
        QCOMPARE(manifest.schemaVersion, 1);
        QCOMPARE(manifest.users.size(), 1);
        QCOMPARE(manifest.modules.size(), 2);
        QVERIFY(manifest.findModule(QStringLiteral("appWeb")) != nullptr);
    }

    void rejectsDuplicateModuleId()
    {
        QByteArray json = validManifest();
        json.replace("\"id\":\"appKline\"", "\"id\":\"appWeb\"");
        ManifestData manifest;
        QString error;
        QVERIFY(!ManifestService::parse(json, &manifest, &error));
        QVERIFY(error.contains(QStringLiteral("重复")));
    }

    void rejectsUnknownRoleReference()
    {
        QByteArray json = validManifest();
        json.replace("\"roleA\":[\"appWeb\",\"appKline\"]",
                     "\"roleA\":[\"missing\",\"appWeb\",\"appKline\"]");
        ManifestData manifest;
        QString error;
        QVERIFY(!ManifestService::parse(json, &manifest, &error));
        QVERIFY(error.contains(QStringLiteral("不存在的模块")));
    }

    void rejectsEscapingQrcPath()
    {
        QByteArray json = validManifest();
        json.replace("qrc:/web-demo/index.html", "qrc:/web-demo/../config/manifest.json");
        ManifestData manifest;
        QString error;
        QVERIFY(!ManifestService::parse(json, &manifest, &error));
    }

    void rejectsNativeArgumentOverflow()
    {
        const QByteArray json = R"json({
          "schemaVersion":1,
          "users":{"demoB":{"password":"demo-only","displayName":"演示用户 B","role":"roleB"}},
          "roles":{"roleB":["appNative"]},
          "modules":[{
            "id":"appNative","type":"native","name":"本机工具","description":"指定麒麟应用",
            "icon":"calculator","status":"等待本机检测","accent":"#9A651A","tint":"#FBF1DF",
            "program":"/opt/star-kylin-demo/not-configured","args":["1","2","3","4","5","6"]
          }]
        })json";
        ManifestData manifest;
        QString error;
        QVERIFY(!ManifestService::parse(json, &manifest, &error));
        QVERIFY(error.contains(QStringLiteral("5 项")));
    }

    void rejectsUnknownSecurityField()
    {
        QByteArray json = validManifest();
        json.replace("\"allowedResourceOrigins\":[]", "\"allowedResourceOrigins\":[],\"allowAll\":true");
        ManifestData manifest;
        QString error;
        QVERIFY(!ManifestService::parse(json, &manifest, &error));
        QVERIFY(error.contains(QStringLiteral("未知字段")));
    }
};

QTEST_APPLESS_MAIN(ManifestTest)
#include "test_manifest.moc"
