#include "appcontroller.h"

#include <QCoreApplication>
#include <QTimer>

AppController::AppController(ManifestData manifest, QString configurationError, QObject *parent)
    : QObject(parent)
    , m_manifest(std::move(manifest))
    , m_configurationError(std::move(configurationError))
    , m_moduleModel(this)
    , m_tabModel(this)
{
    connect(&m_tabModel, &TabListModel::activeIdChanged, this,
            &AppController::activeModuleIdChanged);
}

bool AppController::configurationValid() const
{
    return m_configurationError.isEmpty();
}

QString AppController::configurationError() const
{
    return m_configurationError;
}

bool AppController::authenticated() const
{
    return m_authenticated;
}

bool AppController::loginPending() const
{
    return m_loginPending;
}

QString AppController::loginError() const
{
    return m_loginError;
}

QString AppController::currentUsername() const
{
    return m_currentUser.username;
}

QString AppController::currentDisplayName() const
{
    return m_currentUser.displayName;
}

QString AppController::currentRole() const
{
    return m_currentUser.role;
}

QString AppController::currentInitial() const
{
    return m_currentUser.displayName.isEmpty() ? QStringLiteral("-")
                                                : m_currentUser.displayName.right(1);
}

QString AppController::activeModuleId() const
{
    return m_tabModel.activeId();
}

bool AppController::nativeLaunchPending() const
{
    return m_nativeLaunchPending;
}

ModuleListModel *AppController::moduleModel()
{
    return &m_moduleModel;
}

TabListModel *AppController::tabModel()
{
    return &m_tabModel;
}

void AppController::login(const QString &username, const QString &password)
{
    if (!configurationValid() || m_loginPending) {
        return;
    }
    const QString normalizedUsername = username.trimmed();
    if (normalizedUsername.isEmpty() || password.isEmpty() || normalizedUsername.size() > 64
        || password.size() > 128) {
        setLoginError(QStringLiteral("用户名或密码不正确，请重新输入。"));
        return;
    }

    setLoginError({});
    setLoginPending(true);
    const int attempt = ++m_loginAttempt;
    QTimer::singleShot(350, this, [this, attempt, normalizedUsername, password]() {
        if (attempt != m_loginAttempt) {
            return;
        }
        const auto user = m_authService.authenticate(m_manifest, normalizedUsername, password);
        setLoginPending(false);
        if (!user) {
            setLoginError(QStringLiteral("用户名或密码不正确，请重新输入。"));
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
    m_lastNativeModuleId.clear();
    setNativeLaunchPending(false);
    if (m_authenticated) {
        m_authenticated = false;
        emit authenticatedChanged();
    }
    emit sessionChanged();
}

bool AppController::openModule(const QString &id)
{
    if (!m_authenticated) {
        return false;
    }
    const ModuleDefinition *module = m_moduleModel.find(id);
    if (!module) {
        return false;
    }
    if (module->type == QStringLiteral("native")) {
        launchNativeModule(module->id);
        return true;
    }
    m_tabModel.openModule(*module);
    return true;
}

bool AppController::activateTab(const QString &id)
{
    return m_authenticated && m_tabModel.activate(id);
}

bool AppController::closeTab(const QString &id)
{
    return m_authenticated && m_tabModel.close(id);
}

bool AppController::isWebModule(const QString &id) const
{
    const ModuleDefinition *module = m_moduleModel.find(id);
    return module && module->type == QStringLiteral("web");
}

QUrl AppController::moduleEntryUrl(const QString &id) const
{
    if (!m_authenticated) {
        return {};
    }
    const ModuleDefinition *module = m_moduleModel.find(id);
    if (!module || (module->type != QStringLiteral("web")
                    && module->type != QStringLiteral("kline"))) {
        return {};
    }
    return QUrl(module->entryUrl, QUrl::StrictMode);
}

void AppController::retryNativeModule()
{
    if (!m_lastNativeModuleId.isEmpty()) {
        launchNativeModule(m_lastNativeModuleId);
    }
}

void AppController::quit()
{
    QCoreApplication::quit();
}

void AppController::setLoginPending(bool pending)
{
    if (m_loginPending == pending) {
        return;
    }
    m_loginPending = pending;
    emit loginPendingChanged();
}

void AppController::setLoginError(const QString &error)
{
    if (m_loginError == error) {
        return;
    }
    m_loginError = error;
    emit loginErrorChanged();
}

void AppController::establishSession(const UserDefinition &user)
{
    QList<ModuleDefinition> authorizedModules;
    const QStringList authorizedIds = m_manifest.roles.value(user.role);
    for (const ModuleDefinition &module : m_manifest.modules) {
        if (authorizedIds.contains(module.id)) {
            authorizedModules.append(module);
        }
    }

    m_currentUser = user;
    m_moduleModel.setModules(authorizedModules);
    m_tabModel.reset();
    m_authenticated = true;
    emit sessionChanged();
    emit authenticatedChanged();
}

void AppController::launchNativeModule(const QString &id)
{
    if (!m_authenticated || m_nativeLaunchPending) {
        return;
    }
    const ModuleDefinition *module = m_moduleModel.find(id);
    if (!module || module->type != QStringLiteral("native")) {
        return;
    }

    m_lastNativeModuleId = id;
    setNativeLaunchPending(true);
    QTimer::singleShot(0, this, [this, id]() {
        if (!m_authenticated) {
            setNativeLaunchPending(false);
            return;
        }
        const ModuleDefinition *currentModule = m_moduleModel.find(id);
        if (!currentModule || currentModule->type != QStringLiteral("native")) {
            setNativeLaunchPending(false);
            return;
        }

        const NativeLaunchResult result = NativeLauncher::launch(*currentModule);
        setNativeLaunchPending(false);
        if (result.status == NativeLaunchResult::Status::Started) {
            emit nativeLaunchStarted(currentModule->name, result.pid);
            return;
        }
        if (result.status == NativeLaunchResult::Status::Missing) {
            emit nativeLaunchFailed(
                currentModule->name, QStringLiteral("未找到指定应用"),
                QStringLiteral("请确认验收机已安装清单中的固定应用，然后重新检测。"),
                QStringLiteral("检测目标：清单中的固定应用路径"), QStringLiteral("重新检测"));
            return;
        }
        if (result.status == NativeLaunchResult::Status::InvalidConfiguration) {
            emit nativeLaunchFailed(
                currentModule->name, QStringLiteral("应用配置无效"),
                QStringLiteral("只读清单中的启动配置未通过安全检查。"),
                QStringLiteral("未尝试启动任何程序"), QStringLiteral("重新检测"));
            return;
        }
        emit nativeLaunchFailed(
            currentModule->name, QStringLiteral("应用启动失败"),
            QStringLiteral("指定应用未能启动，请检查应用状态后重试。"),
            QStringLiteral("启动结果：未能创建目标进程"), QStringLiteral("重试"));
    });
}

void AppController::setNativeLaunchPending(bool pending)
{
    if (m_nativeLaunchPending == pending) {
        return;
    }
    m_nativeLaunchPending = pending;
    emit nativeLaunchPendingChanged();
}
