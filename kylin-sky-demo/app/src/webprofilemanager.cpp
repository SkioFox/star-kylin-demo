#include "webprofilemanager.h"

#include <QWebEngineCookieStore>
#include <QWebEngineUrlRequestInfo>
#include <QWebEngineUrlRequestInterceptor>

namespace {
class Interceptor final : public QWebEngineUrlRequestInterceptor {
public:
    Interceptor(const UrlPolicy *policy, QString moduleId, QObject *parent) : QWebEngineUrlRequestInterceptor(parent), m_policy(policy), m_moduleId(std::move(moduleId)) {}
    void interceptRequest(QWebEngineUrlRequestInfo &info) override { info.block(!m_policy->resourceAllowed(m_moduleId, info.requestUrl())); }
private: const UrlPolicy *m_policy; QString m_moduleId;
};
}
WebProfileManager::WebProfileManager(const ManifestData &manifest, QObject *parent) : QObject(parent), m_policy(manifest)
{
    for (const ModuleDefinition &module : manifest.modules) {
        if (module.type != QStringLiteral("web")) continue;
        auto *profile = new QQuickWebEngineProfile(this);
        profile->setOffTheRecord(true);
        profile->setHttpCacheType(QQuickWebEngineProfile::MemoryHttpCache);
        profile->setPersistentCookiesPolicy(QQuickWebEngineProfile::NoPersistentCookies);
        profile->setSpellCheckEnabled(false);
        auto *interceptor = new Interceptor(&m_policy, module.id, profile);
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
        profile->setRequestInterceptor(interceptor);
#else
        profile->setUrlRequestInterceptor(interceptor);
#endif
        m_profiles.insert(module.id, profile);
    }
}
QQuickWebEngineProfile *WebProfileManager::profile(const QString &moduleId) const { return m_profiles.value(moduleId); }
bool WebProfileManager::navigationAllowed(const QString &moduleId, const QUrl &url) const { return m_policy.navigationAllowed(moduleId, url); }
void WebProfileManager::clearSessions() { for (auto *profile : m_profiles) { profile->cookieStore()->deleteAllCookies(); profile->clearHttpCache(); } }
