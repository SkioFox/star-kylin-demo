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
    , m_klineProfile(new QQuickWebEngineProfile(this))
{
    configureOffTheRecordProfile(m_klineProfile, QQuickWebEngineProfile::NoCache);

    auto *klineInterceptor = new PolicyRequestInterceptor(
        &m_policy, firstModuleId(manifest, QStringLiteral("kline")), m_klineProfile);
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    m_klineProfile->setRequestInterceptor(klineInterceptor);
#else
    m_klineProfile->setUrlRequestInterceptor(klineInterceptor);
#endif

    for (const ModuleDefinition &module : manifest.modules) {
        if (module.type != QStringLiteral("web")) {
            continue;
        }
        auto *profile = new QQuickWebEngineProfile(this);
        configureOffTheRecordProfile(profile, QQuickWebEngineProfile::MemoryHttpCache);
        auto *interceptor = new PolicyRequestInterceptor(&m_policy, module.id, profile);
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
        profile->setRequestInterceptor(interceptor);
#else
        profile->setUrlRequestInterceptor(interceptor);
#endif
        m_webProfiles.insert(module.id, profile);
        if (!m_businessProfile) {
            m_businessProfile = profile;
        }
    }
}

QQuickWebEngineProfile *WebProfileManager::businessProfile() const
{
    return m_businessProfile;
}

QQuickWebEngineProfile *WebProfileManager::klineProfile() const
{
    return m_klineProfile;
}

QQuickWebEngineProfile *WebProfileManager::webProfile(const QString &moduleId) const
{
    return m_webProfiles.value(moduleId, m_businessProfile);
}

bool WebProfileManager::isNavigationAllowed(const QString &moduleId, const QUrl &url) const
{
    return m_policy.isNavigationAllowed(moduleId, url);
}

void WebProfileManager::clearBusinessSession()
{
    for (QQuickWebEngineProfile *profile : m_webProfiles) {
        profile->cookieStore()->deleteAllCookies();
        profile->clearHttpCache();
    }
}
