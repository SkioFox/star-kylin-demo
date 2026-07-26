#pragma once

#include "manifestservice.h"
#include "mockauthservice.h"
#include "modulelistmodel.h"
#include "nativelauncher.h"
#include "tablistmodel.h"

#include <QObject>
#include <QUrl>

class AppController final : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool configurationValid READ configurationValid CONSTANT)
    Q_PROPERTY(QString configurationError READ configurationError CONSTANT)
    Q_PROPERTY(bool authenticated READ authenticated NOTIFY authenticatedChanged)
    Q_PROPERTY(bool loginPending READ loginPending NOTIFY loginPendingChanged)
    Q_PROPERTY(QString loginError READ loginError NOTIFY loginErrorChanged)
    Q_PROPERTY(QString currentUsername READ currentUsername NOTIFY sessionChanged)
    Q_PROPERTY(QString currentDisplayName READ currentDisplayName NOTIFY sessionChanged)
    Q_PROPERTY(QString currentRole READ currentRole NOTIFY sessionChanged)
    Q_PROPERTY(QString currentInitial READ currentInitial NOTIFY sessionChanged)
    Q_PROPERTY(QString activeModuleId READ activeModuleId NOTIFY activeModuleIdChanged)
    Q_PROPERTY(bool nativeLaunchPending READ nativeLaunchPending NOTIFY nativeLaunchPendingChanged)
    Q_PROPERTY(ModuleListModel *moduleModel READ moduleModel CONSTANT)
    Q_PROPERTY(TabListModel *tabModel READ tabModel CONSTANT)

public:
    explicit AppController(ManifestData manifest, QString configurationError,
                           QObject *parent = nullptr);

    bool configurationValid() const;
    QString configurationError() const;
    bool authenticated() const;
    bool loginPending() const;
    QString loginError() const;
    QString currentUsername() const;
    QString currentDisplayName() const;
    QString currentRole() const;
    QString currentInitial() const;
    QString activeModuleId() const;
    bool nativeLaunchPending() const;
    ModuleListModel *moduleModel();
    TabListModel *tabModel();

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool openModule(const QString &id);
    Q_INVOKABLE bool activateTab(const QString &id);
    Q_INVOKABLE bool closeTab(const QString &id);
    Q_INVOKABLE bool isWebModule(const QString &id) const;
    Q_INVOKABLE QUrl moduleEntryUrl(const QString &id) const;
    Q_INVOKABLE void retryNativeModule();
    Q_INVOKABLE void quit();

signals:
    void authenticatedChanged();
    void loginPendingChanged();
    void loginErrorChanged();
    void sessionChanged();
    void activeModuleIdChanged();
    void nativeLaunchPendingChanged();
    void nativeLaunchFailed(const QString &name, const QString &title, const QString &message,
                            const QString &detail, const QString &retryText);
    void nativeLaunchStarted(const QString &name, qint64 pid);

private:
    void setLoginPending(bool pending);
    void setLoginError(const QString &error);
    void establishSession(const UserDefinition &user);
    void launchNativeModule(const QString &id);
    void setNativeLaunchPending(bool pending);

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
    bool m_nativeLaunchPending = false;
    QString m_lastNativeModuleId;
};
