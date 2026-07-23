#include "webprofilemanager.h"

#include <QWebEngineCookieStore>
#include <QWebEngineUrlRequestInfo>
#include <QWebEngineUrlRequestInterceptor>

namespace {

class PolicyRequestInterceptor final : public QWebEngineUrlRequestInterceptor {
public:
    PolicyRequestInterceptor(const UrlPolicy *policy, QString moduleId, QObject *parent)
        : QWebEngineUrlRequestInterceptor(parent)
        , m_policy(policy)
        , m_moduleId(std::move(moduleId))
    {
    }

    void interceptRequest(QWebEngineUrlRequestInfo &info) override
    {
        info.block(!m_policy->isResourceAllowed(m_moduleId, info.requestUrl()));
    }

private:
    const UrlPolicy *m_policy;
    const QString m_moduleId;
};

QString firstModuleId(const ManifestData &manifest, const QString &type)
{
    for (const ModuleDefinition &module : manifest.modules) {
        if (module.type == type) {
            return module.id;
        }
    }
    return {};
}

void configureOffTheRecordProfile(QQuickWebEngineProfile *profile,
                                  QQuickWebEngineProfile::HttpCacheType cacheType)
{
    profile->setOffTheRecord(true);
    profile->setHttpCacheType(cacheType);
    profile->setPersistentCookiesPolicy(QQuickWebEngineProfile::NoPersistentCookies);
    profile->setSpellCheckEnabled(false);
}

} // namespace

WebProfileManager::WebProfileManager(const ManifestData &manifest, QObject *parent)
    : QObject(parent)
    , m_policy(manifest)
    , m_businessProfile(new QQuickWebEngineProfile(this))
    , m_klineProfile(new QQuickWebEngineProfile(this))
{
    configureOffTheRecordProfile(m_businessProfile, QQuickWebEngineProfile::MemoryHttpCache);
    configureOffTheRecordProfile(m_klineProfile, QQuickWebEngineProfile::NoCache);

    auto *businessInterceptor = new PolicyRequestInterceptor(
        &m_policy, firstModuleId(manifest, QStringLiteral("web")), m_businessProfile);
    auto *klineInterceptor = new PolicyRequestInterceptor(
        &m_policy, firstModuleId(manifest, QStringLiteral("kline")), m_klineProfile);
    m_businessProfile->setUrlRequestInterceptor(businessInterceptor);
    m_klineProfile->setUrlRequestInterceptor(klineInterceptor);
}

QQuickWebEngineProfile *WebProfileManager::businessProfile() const
{
    return m_businessProfile;
}

QQuickWebEngineProfile *WebProfileManager::klineProfile() const
{
    return m_klineProfile;
}

bool WebProfileManager::isNavigationAllowed(const QString &moduleId, const QUrl &url) const
{
    return m_policy.isNavigationAllowed(moduleId, url);
}

void WebProfileManager::clearBusinessSession()
{
    m_businessProfile->cookieStore()->deleteAllCookies();
    m_businessProfile->clearHttpCache();
}
