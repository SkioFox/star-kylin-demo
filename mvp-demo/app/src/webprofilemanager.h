#pragma once

#include "manifestservice.h"
#include "urlpolicy.h"

#include <QHash>
#include <QObject>

#if QT_VERSION_MAJOR >= 6
#include <QtWebEngineQuick/QQuickWebEngineProfile>
#else
#include <QtWebEngine/QQuickWebEngineProfile>
#endif

class WebProfileManager final : public QObject {
    Q_OBJECT
    Q_PROPERTY(QQuickWebEngineProfile *businessProfile READ businessProfile CONSTANT)
    Q_PROPERTY(QQuickWebEngineProfile *klineProfile READ klineProfile CONSTANT)

public:
    explicit WebProfileManager(const ManifestData &manifest, QObject *parent = nullptr);

    QQuickWebEngineProfile *businessProfile() const;
    QQuickWebEngineProfile *klineProfile() const;

    Q_INVOKABLE QQuickWebEngineProfile *webProfile(const QString &moduleId) const;
    Q_INVOKABLE bool isNavigationAllowed(const QString &moduleId, const QUrl &url) const;
    Q_INVOKABLE void clearBusinessSession();

private:
    UrlPolicy m_policy;
    QQuickWebEngineProfile *m_businessProfile = nullptr;
    QQuickWebEngineProfile *m_klineProfile = nullptr;
    QHash<QString, QQuickWebEngineProfile *> m_webProfiles;
};
