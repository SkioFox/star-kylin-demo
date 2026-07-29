#include "appcontroller.h"

#include <QtTest>

class AppControllerTest final : public QObject {
    Q_OBJECT
private slots:
    void rejectsInvalidCredentials();
    void filtersModulesAndMaintainsSingleTabs();
    void logoutClearsTheSession();

private:
    ManifestData manifest() const;
};

ManifestData AppControllerTest::manifest() const
{
    ManifestData result;
    QString error;
    if (!ManifestService::load(QStringLiteral(":/config/manifest.json"), &result, &error))
        qFatal("Unable to load test manifest: %s", qPrintable(error));
    return result;
}

void AppControllerTest::rejectsInvalidCredentials()
{
    AppController controller(manifest(), {});
    QVERIFY(!controller.openModule(QStringLiteral("market")));

    controller.login(QStringLiteral("operator"), QStringLiteral("wrong"));
    QTRY_VERIFY(!controller.loginPending());
    QVERIFY(!controller.authenticated());
    QCOMPARE(controller.loginError(), QStringLiteral("用户名或密码不正确，请检查后重试。"));
}

void AppControllerTest::filtersModulesAndMaintainsSingleTabs()
{
    AppController controller(manifest(), {});
    controller.login(QStringLiteral("auditor"), QStringLiteral("AuditDemo2026"));
    QTRY_VERIFY(controller.authenticated());
    QCOMPARE(controller.moduleModel()->rowCount(), 8);
    QVERIFY(!controller.openModule(QStringLiteral("external")));

    QVERIFY(controller.openModule(QStringLiteral("market")));
    QCOMPARE(controller.tabModel()->rowCount(), 2);
    QCOMPARE(controller.activeModuleId(), QStringLiteral("market"));
    QVERIFY(controller.openModule(QStringLiteral("market")));
    QCOMPARE(controller.tabModel()->rowCount(), 2);
    QVERIFY(controller.closeTab(QStringLiteral("market")));
    QCOMPARE(controller.activeModuleId(), QStringLiteral("workbench"));
    QVERIFY(!controller.closeTab(QStringLiteral("workbench")));
}

void AppControllerTest::logoutClearsTheSession()
{
    AppController controller(manifest(), {});
    controller.login(QStringLiteral("operator"), QStringLiteral("KylinDemo2026"));
    QTRY_VERIFY(controller.authenticated());
    QVERIFY(controller.openModule(QStringLiteral("external")));

    controller.logout();
    QVERIFY(!controller.authenticated());
    QCOMPARE(controller.moduleModel()->rowCount(), 0);
    QCOMPARE(controller.tabModel()->rowCount(), 1);
    QCOMPARE(controller.activeModuleId(), QStringLiteral("workbench"));
    QVERIFY(!controller.activateTab(QStringLiteral("external")));
}

QTEST_MAIN(AppControllerTest)
#include "test_appcontroller.moc"
