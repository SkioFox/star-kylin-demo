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
    manifest.modules = {local, remote};
    const UrlPolicy policy(manifest);
    const bool valid = policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/index.html")))
                       && !policy.navigationAllowed(QStringLiteral("local"), QUrl(QStringLiteral("qrc:/web-demo/../config/manifest.json")))
                       && policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/path")))
                       && !policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("http://service.example/path")))
                       && !policy.navigationAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example:444/path")))
                       && policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://static.example:8443/app.js")))
                       && !policy.resourceAllowed(QStringLiteral("remote"), QUrl(QStringLiteral("https://service.example/app.js")));
    if (!valid) qCritical() << "URL policy boundary regression";
    return valid ? 0 : 1;
}
