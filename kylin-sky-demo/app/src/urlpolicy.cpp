#include "urlpolicy.h"

namespace {
QString decodedPath(const QUrl &url)
{
    const QString path = url.path(QUrl::FullyDecoded);
    if (!path.startsWith(QLatin1Char('/'))) return {};
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    const QStringList segments = path.split(QLatin1Char('/'), QString::KeepEmptyParts);
#else
    const QStringList segments = path.split(QLatin1Char('/'), Qt::KeepEmptyParts);
#endif
    return segments.contains(QStringLiteral(".")) || segments.contains(QStringLiteral("..")) ? QString() : path;
}
}

UrlPolicy::UrlPolicy(const ManifestData &manifest)
{
    for (const ModuleDefinition &module : manifest.modules) {
        if (module.type != QStringLiteral("web")) continue;
        Rules rules; rules.localPrefixes = module.allowedLocalPrefixes;
        for (const QString &origin : module.allowedNavigationOrigins) rules.navigationOrigins.append(httpsOrigin(QUrl(origin, QUrl::StrictMode)));
        for (const QString &origin : module.allowedResourceOrigins) rules.resourceOrigins.append(httpsOrigin(QUrl(origin, QUrl::StrictMode)));
        m_rules.insert(module.id, rules);
    }
}
bool UrlPolicy::navigationAllowed(const QString &moduleId, const QUrl &url) const
{
    const auto rules = m_rules.constFind(moduleId);
    if (rules == m_rules.constEnd() || !url.isValid() || !url.userInfo().isEmpty()) return false;
    return url.scheme().compare(QStringLiteral("qrc"), Qt::CaseInsensitive) == 0
               ? localAllowed(url, rules->localPrefixes)
               : rules->navigationOrigins.contains(httpsOrigin(url));
}
bool UrlPolicy::resourceAllowed(const QString &moduleId, const QUrl &url) const
{
    const auto rules = m_rules.constFind(moduleId);
    if (rules == m_rules.constEnd() || !url.isValid() || !url.userInfo().isEmpty()) return false;
    return url.scheme().compare(QStringLiteral("qrc"), Qt::CaseInsensitive) == 0
               ? localAllowed(url, rules->localPrefixes)
               : rules->resourceOrigins.contains(httpsOrigin(url));
}
QString UrlPolicy::httpsOrigin(const QUrl &url)
{
    if (!url.isValid() || url.scheme().compare(QStringLiteral("https"), Qt::CaseInsensitive) != 0 || url.host().isEmpty() || !url.userInfo().isEmpty()) return {};
    QString result = QStringLiteral("https://") + url.host(QUrl::FullyEncoded).toLower();
    if (url.port(-1) != -1 && url.port(-1) != 443) result += QLatin1Char(':') + QString::number(url.port());
    return result;
}
bool UrlPolicy::localAllowed(const QUrl &url, const QStringList &prefixes)
{
    if (!url.host().isEmpty()) return false;
    const QString path = decodedPath(url);
    if (path.isEmpty()) return false;
    for (const QString &value : prefixes) {
        const QUrl prefix(value, QUrl::StrictMode);
        const QString prefixPath = decodedPath(prefix);
        if (prefix.scheme() == QStringLiteral("qrc") && prefix.host().isEmpty() && !prefixPath.isEmpty()
            && path.startsWith(prefixPath.endsWith(QLatin1Char('/')) ? prefixPath : prefixPath + QLatin1Char('/'))) return true;
    }
    return false;
}
