#pragma once

#include "manifestservice.h"

#include <QHash>
#include <QUrl>

class UrlPolicy final {
public:
    explicit UrlPolicy(const ManifestData &manifest);
    bool navigationAllowed(const QString &moduleId, const QUrl &url) const;
    bool resourceAllowed(const QString &moduleId, const QUrl &url) const;
private:
    struct Rules { QStringList localPrefixes; QStringList navigationOrigins; QStringList resourceOrigins; };
    static QString httpsOrigin(const QUrl &url);
    static bool localAllowed(const QUrl &url, const QStringList &prefixes);
    QHash<QString, Rules> m_rules;
};
