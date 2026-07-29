#include "manifestservice.h"

#include <QCoreApplication>
#include <QDebug>

namespace {
bool parseSucceeds(const QByteArray &json)
{
    ManifestData manifest;
    QString error;
    if (ManifestService::parse(json, &manifest, &error)) return true;
    qCritical().noquote() << error;
    return false;
}

bool parseFailsWith(const QByteArray &json, const QString &expected)
{
    ManifestData manifest;
    QString error;
    if (!ManifestService::parse(json, &manifest, &error) && error.contains(expected)) return true;
    qCritical().noquote() << QStringLiteral("未得到预期校验错误：") << error;
    return false;
}
} // namespace

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
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
    const QByteArray overflow = R"json({
      "schemaVersion":1,
      "users":{"operator":{"password":"demo","displayName":"运营主管","role":"主管"}},
      "roles":{"主管":["native"]},
      "modules":[{"id":"native","type":"native","name":"工具","description":"固定路径","group":"应用服务","program":"/usr/bin/tool","args":["1","2","3","4","5","6"]}]
    })json";
    return parseSucceeds(valid) && parseFailsWith(unapproved, QStringLiteral("精确授权"))
               && parseFailsWith(overflow, QStringLiteral("原生启动配置"))
           ? 0
           : 1;
}
