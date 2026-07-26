#include "urlpolicy.h"

namespace {

QString decodedPath(const QUrl &url)
{
    const QString path = url.path(QUrl::FullyDecoded);
    if (!path.startsWith(QLatin1Char('/'))) {
        return {};
    }
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    const QStringList segments = path.split(QLatin1Char('/'), QString::KeepEmptyParts);
#else
    const QStringList segments = path.split(QLatin1Char('/'), Qt::KeepEmptyParts);
#endif
    if (segments.contains(QStringLiteral(".")) || segments.contains(QStringLiteral(".."))) {
        return {};
    }
    return path;
}

} // namespace

UrlPolicy::UrlPolicy(const ManifestData &manifest)
{
    for (const ModuleDefinition &module : manifest.modules) {
        Rules rules;
        rules.type = module.type;
        rules.localPrefixes = module.allowedLocalPrefixes;
        if (module.type == QStringLiteral("kline")) {
            const QUrl entry(module.entryUrl, QUrl::StrictMode);
            const QString entryPath = decodedPath(entry);
            const int separator = entryPath.lastIndexOf(QLatin1Char('/'));
            if (separator >= 0) {
                rules.localPrefixes = QStringList{
                    QStringLiteral("qrc:") + entryPath.left(separator + 1)};
            }
        }
        rules.navigationOrigins = normalizedOrigins(module.allowedNavigationOrigins);
        rules.resourceOrigins = normalizedOrigins(module.allowedResourceOrigins);
        m_rules.insert(module.id, rules);
    }
}

bool UrlPolicy::isNavigationAllowed(const QString &moduleId, const QUrl &url) const
{
    const auto rules = m_rules.constFind(moduleId);
    if (rules == m_rules.constEnd() || !url.isValid() || !url.userInfo().isEmpty()) {
        return false;
    }
    if (url.scheme().compare(QStringLiteral("qrc"), Qt::CaseInsensitive) == 0) {
        return isLocalUrlAllowed(url, rules->localPrefixes);
    }
    const QString origin = normalizedHttpsOrigin(url);
    return !origin.isEmpty() && rules->navigationOrigins.contains(origin);
}

bool UrlPolicy::isResourceAllowed(const QString &moduleId, const QUrl &url) const
{
    const auto rules = m_rules.constFind(moduleId);
    if (rules == m_rules.constEnd() || !url.isValid() || !url.userInfo().isEmpty()) {
        return false;
    }
    if (url.scheme().compare(QStringLiteral("qrc"), Qt::CaseInsensitive) == 0) {
        return isLocalUrlAllowed(url, rules->localPrefixes);
    }
    const QString origin = normalizedHttpsOrigin(url);
    return !origin.isEmpty() && rules->resourceOrigins.contains(origin);
}

QString UrlPolicy::normalizedHttpsOrigin(const QUrl &url)
{
    if (!url.isValid() || url.scheme().compare(QStringLiteral("https"), Qt::CaseInsensitive) != 0
        || url.host().isEmpty() || !url.userInfo().isEmpty()) {
        return {};
    }
    const int port = url.port(443);
    if (port < 1 || port > 65535) {
        return {};
    }
    QUrl origin;
    origin.setScheme(QStringLiteral("https"));
    origin.setHost(url.host().toLower());
    origin.setPort(port);
    return origin.toString(QUrl::FullyEncoded | QUrl::RemovePath | QUrl::RemoveQuery
                           | QUrl::RemoveFragment | QUrl::RemoveUserInfo);
}

bool UrlPolicy::isLocalUrlAllowed(const QUrl &url, const QStringList &prefixes)
{
    if (!url.host().isEmpty()) {
        return false;
    }
    const QString requestPath = decodedPath(url);
    if (requestPath.isEmpty()) {
        return false;
    }
    for (const QString &prefixValue : prefixes) {
        const QUrl prefix(prefixValue, QUrl::StrictMode);
        if (prefix.scheme().compare(QStringLiteral("qrc"), Qt::CaseInsensitive) != 0
            || !prefix.host().isEmpty()) {
            continue;
        }
        QString prefixPath = decodedPath(prefix);
        if (prefixPath.isEmpty()) {
            continue;
        }
        if (!prefixPath.endsWith(QLatin1Char('/'))) {
            prefixPath.append(QLatin1Char('/'));
        }
        if (requestPath.startsWith(prefixPath)) {
            return true;
        }
    }
    return false;
}

QStringList UrlPolicy::normalizedOrigins(const QStringList &origins)
{
    QStringList result;
    for (const QString &origin : origins) {
        const QString normalized = normalizedHttpsOrigin(QUrl(origin, QUrl::StrictMode));
        if (!normalized.isEmpty()) {
            result.append(normalized);
        }
    }
    return result;
}
