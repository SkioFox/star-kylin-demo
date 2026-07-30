#include "urlpolicy.h"

#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
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
    baidu.name = QStringLiteral("百度");
    baidu.entryUrl = QStringLiteral("https://www.baidu.com/");
    baidu.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.baidu.com");
    baidu.allowedResourceOrigins = QStringList() << QStringLiteral("https://www.baidu.com");
    ApprovedPageDefinition bilibili;
    bilibili.id = QStringLiteral("bilibili");
    bilibili.name = QStringLiteral("哔哩哔哩");
    bilibili.entryUrl = QStringLiteral("https://www.bilibili.com/");
    bilibili.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.bilibili.com");
    bilibili.allowedResourceOrigins = QStringList() << QStringLiteral("https://www.bilibili.com");
    ModuleDefinition external;
    external.id = QStringLiteral("external");
    external.type = QStringLiteral("web");
    external.allowedNavigationOrigins = QStringList() << QStringLiteral("https://www.baidu.com") << QStringLiteral("https://www.bilibili.com");
    external.allowedResourceOrigins = external.allowedNavigationOrigins;
    external.approvedPages = {baidu, bilibili};
    manifest.modules = {local, remote, external};
    const UrlPolicy policy(manifest);
    const bool valid = policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/index.html")))
                       && !policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/../config/manifest.json")))
                       && policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/path")))
                       && !policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("http://service.example/path")))
                       && !policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example:444/path")))
                       && policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://static.example:8443/app.js")))
                       && !policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/app.js")));
    const bool pageIsolation = policy.navigationAllowed(QStringLiteral("external#baidu"), QUrl(QStringLiteral("https://www.baidu.com/s")))
                               && !policy.navigationAllowed(QStringLiteral("external#baidu"), QUrl(QStringLiteral("https://www.bilibili.com/")))
                               && policy.resourceAllowed(QStringLiteral("external#bilibili"), QUrl(QStringLiteral("https://www.bilibili.com/assets/app.js")))
                               && !policy.resourceAllowed(QStringLiteral("external#bilibili"), QUrl(QStringLiteral("https://www.baidu.com/app.js")));
    if (!valid || !pageIsolation) qCritical() << "URL policy boundary regression";
    return valid && pageIsolation ? 0 : 1;
}
