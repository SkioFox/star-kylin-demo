#include "appcontroller.h"
#include "nativelauncher.h"

#include <QTimer>

AppController::AppController(ManifestData manifest, QString configurationError, QObject *parent)
    : QObject(parent)
    , m_manifest(std::move(manifest))
    , m_configurationError(std::move(configurationError))
    , m_moduleModel(this)
    , m_tabModel(this)
{
    connect(&m_tabModel, &TabListModel::activeIdChanged, this, &AppController::activeModuleIdChanged);
}

bool AppController::authenticated() const { return m_authenticated; }
bool AppController::configurationValid() const { return m_configurationError.isEmpty(); }
QString AppController::configurationError() const { return m_configurationError; }
QString AppController::loginError() const { return m_loginError; }
QString AppController::displayRole() const { return m_currentUser.role; }
QString AppController::displayName() const { return m_currentUser.displayName; }
bool AppController::loginPending() const { return m_loginPending; }
QString AppController::activeModuleId() const { return m_tabModel.activeId(); }
QString AppController::activeModuleName() const { return m_tabModel.activeName(); }
ModuleListModel *AppController::moduleModel() { return &m_moduleModel; }
TabListModel *AppController::tabModel() { return &m_tabModel; }

void AppController::login(const QString &username, const QString &password)
{
    if (!configurationValid() || m_loginPending) return;
    const QString normalizedUsername = username.trimmed();
    if (normalizedUsername.isEmpty() || password.isEmpty() || normalizedUsername.size() > 64
        || password.size() > 128) {
        setLoginError(QStringLiteral("用户名或密码不正确，请检查后重试。"));
        return;
    }
    setLoginError({});
    setLoginPending(true);
    const int attempt = ++m_loginAttempt;
    QTimer::singleShot(450, this, [this, attempt, normalizedUsername, password]() {
        if (attempt != m_loginAttempt) return;
        const auto user = m_authService.authenticate(m_manifest, normalizedUsername, password);
        setLoginPending(false);
        if (!user) {
            setLoginError(QStringLiteral("用户名或密码不正确，请检查后重试。"));
            return;
        }
        establishSession(*user);
    });
}

void AppController::logout()
{
    ++m_loginAttempt;
    setLoginPending(false);
    setLoginError({});
    m_moduleModel.setModules({});
    m_tabModel.reset();
    m_currentUser = {};
    if (m_authenticated) {
        m_authenticated = false;
        emit authenticatedChanged();
    }
    emit sessionChanged();
}

bool AppController::openModule(const QString &id)
{
    if (!m_authenticated) return false;
    const ModuleDefinition *module = m_moduleModel.find(id);
    if (!module) return false;
    m_tabModel.openModule(*module);
    return true;
}

bool AppController::activateTab(const QString &id) { return m_authenticated && m_tabModel.activate(id); }
bool AppController::closeTab(const QString &id) { return m_authenticated && m_tabModel.close(id); }
QUrl AppController::moduleEntryUrl(const QString &id) const { const ModuleDefinition *module = m_authenticated ? m_moduleModel.find(id) : nullptr; return module && module->type == QStringLiteral("web") ? QUrl(module->entryUrl, QUrl::StrictMode) : QUrl(); }
QUrl AppController::moduleEntryUrlForPage(const QString &id, const QString &pageId) const
{
    const ModuleDefinition *module = m_authenticated ? m_moduleModel.find(id) : nullptr;
    if (!module || module->type != QStringLiteral("web")) return {};
    for (const ApprovedPageDefinition &page : module->approvedPages)
        if (page.id == pageId) return QUrl(page.entryUrl, QUrl::StrictMode);
    return {};
}
QVariantList AppController::approvedPages(const QString &id) const
{
    QVariantList result;
    const ModuleDefinition *module = m_authenticated ? m_moduleModel.find(id) : nullptr;
    if (!module || module->type != QStringLiteral("web")) return result;
    for (const ApprovedPageDefinition &page : module->approvedPages) {
        QVariantMap value;
        value.insert(QStringLiteral("id"), page.id);
        value.insert(QStringLiteral("name"), page.name);
        value.insert(QStringLiteral("entryUrl"), page.entryUrl);
        result.append(value);
    }
    return result;
}
bool AppController::isWebModule(const QString &id) const { const ModuleDefinition *module = m_moduleModel.find(id); return m_authenticated && module && module->type == QStringLiteral("web"); }
QString AppController::launchNativeModule(const QString &id) const { const ModuleDefinition *module = allowedModule(id); return module ? NativeLauncher::launch(*module) : QStringLiteral("未授权或不存在的本机应用。"); }

const ModuleDefinition *AppController::allowedModule(const QString &id) const
{
    if (!m_authenticated || !m_manifest.roles.value(m_currentUser.role).contains(id)) return nullptr;
    for (const ModuleDefinition &module : m_manifest.modules)
        if (module.id == id) return &module;
    return nullptr;
}

void AppController::setLoginError(const QString &error)
{
    if (m_loginError == error) return;
    m_loginError = error;
    emit loginErrorChanged();
}

void AppController::setLoginPending(bool pending)
{
    if (m_loginPending == pending) return;
    m_loginPending = pending;
    emit loginPendingChanged();
}

void AppController::establishSession(const UserDefinition &user)
{
    QList<ModuleDefinition> modules;
    const QStringList allowed = m_manifest.roles.value(user.role);
    for (const ModuleDefinition &module : m_manifest.modules)
        if (allowed.contains(module.id) && module.showInNavigation) modules.append(module);
    m_currentUser = user;
    m_moduleModel.setModules(modules);
    m_tabModel.reset();
    m_authenticated = true;
    emit sessionChanged();
    emit authenticatedChanged();
}
