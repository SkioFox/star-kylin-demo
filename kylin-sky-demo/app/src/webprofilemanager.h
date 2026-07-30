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
public:
    explicit WebProfileManager(const ManifestData &manifest, QObject *parent = nullptr);
    Q_INVOKABLE QQuickWebEngineProfile *profile(const QString &moduleId) const;
    Q_INVOKABLE QQuickWebEngineProfile *profileForPage(const QString &moduleId, const QString &pageId) const;
    Q_INVOKABLE bool navigationAllowed(const QString &moduleId, const QUrl &url) const;
    Q_INVOKABLE bool navigationAllowedForPage(const QString &moduleId, const QString &pageId, const QUrl &url) const;
    Q_INVOKABLE void clearSessions();
private:
    QQuickWebEngineProfile *createProfile(const QString &policyId);
    UrlPolicy m_policy;
    QHash<QString, QQuickWebEngineProfile *> m_profiles;
};
