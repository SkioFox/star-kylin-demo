#pragma once

#include "manifestservice.h"
#include "mockauthservice.h"
#include "modulelistmodel.h"
#include "tablistmodel.h"

#include <QObject>
#include <QUrl>
#include <QVariantList>

class AppController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged)
    Q_PROPERTY(bool configurationValid READ configurationValid CONSTANT)
    Q_PROPERTY(QString configurationError READ configurationError CONSTANT)
    Q_PROPERTY(QString loginError READ loginError NOTIFY loginErrorChanged)
    Q_PROPERTY(QString displayRole READ displayRole NOTIFY sessionChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY sessionChanged)
    Q_PROPERTY(bool loginPending READ loginPending NOTIFY loginPendingChanged)
    Q_PROPERTY(QString activeModuleId READ activeModuleId NOTIFY activeModuleIdChanged)
    Q_PROPERTY(QString activeModuleName READ activeModuleName NOTIFY activeModuleIdChanged)
    Q_PROPERTY(ModuleListModel *moduleModel READ moduleModel CONSTANT)
    Q_PROPERTY(TabListModel *tabModel READ tabModel CONSTANT)

public:
    explicit AppController(ManifestData manifest, QString configurationError, QObject *parent = nullptr);
    bool authenticated() const;
    bool configurationValid() const;
    QString configurationError() const;
    QString loginError() const;
    QString displayRole() const;
    QString displayName() const;
    bool loginPending() const;
    QString activeModuleId() const;
    QString activeModuleName() const;
    ModuleListModel *moduleModel();
    TabListModel *tabModel();

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool openModule(const QString &id);
    Q_INVOKABLE bool activateTab(const QString &id);
    Q_INVOKABLE bool closeTab(const QString &id);
    Q_INVOKABLE QUrl moduleEntryUrl(const QString &id) const;
    Q_INVOKABLE QUrl moduleEntryUrlForPage(const QString &id, const QString &pageId) const;
    Q_INVOKABLE QVariantList approvedPages(const QString &id) const;
    Q_INVOKABLE bool isWebModule(const QString &id) const;
    Q_INVOKABLE QString launchNativeModule(const QString &id) const;

signals:
    void authenticatedChanged();
    void loginErrorChanged();
    void loginPendingChanged();
    void sessionChanged();
    void activeModuleIdChanged();

private:
    const ModuleDefinition *allowedModule(const QString &id) const;
    void setLoginError(const QString &error);
    void setLoginPending(bool pending);
    void establishSession(const UserDefinition &user);
    ManifestData m_manifest;
    QString m_configurationError;
    MockAuthService m_authService;
    ModuleListModel m_moduleModel;
    TabListModel m_tabModel;
    bool m_authenticated = false;
    bool m_loginPending = false;
    QString m_loginError;
    UserDefinition m_currentUser;
    int m_loginAttempt = 0;
};
