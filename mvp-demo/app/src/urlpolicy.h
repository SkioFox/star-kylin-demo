#pragma once

#include "manifestservice.h"

#include <QHash>
#include <QUrl>

class UrlPolicy final {
public:
    explicit UrlPolicy(const ManifestData &manifest);

    bool isNavigationAllowed(const QString &moduleId, const QUrl &url) const;
    bool isResourceAllowed(const QString &moduleId, const QUrl &url) const;
    static QString normalizedHttpsOrigin(const QUrl &url);

private:
    struct Rules {
        QString type;
        QStringList localPrefixes;
        QStringList navigationOrigins;
        QStringList resourceOrigins;
    };

    static bool isLocalUrlAllowed(const QUrl &url, const QStringList &prefixes);
    static QStringList normalizedOrigins(const QStringList &origins);

    QHash<QString, Rules> m_rules;
};
