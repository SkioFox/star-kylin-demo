#include "appcontroller.h"

#include <QtTest>

namespace {

ManifestData testManifest()
{
    ManifestData manifest;
    manifest.schemaVersion = 1;
    manifest.users.insert(
        QStringLiteral("demoA"),
        {QStringLiteral("demoA"), QStringLiteral("demo-only"),
         QStringLiteral("演示用户 A"), QStringLiteral("roleA")});
    manifest.roles.insert(QStringLiteral("roleA"),
                          {QStringLiteral("appWeb"), QStringLiteral("appKline")});
    manifest.users.insert(
        QStringLiteral("demoB"),
        {QStringLiteral("demoB"), QStringLiteral("demo-only"),
         QStringLiteral("演示用户 B"), QStringLiteral("roleB")});
    manifest.roles.insert(QStringLiteral("roleB"),
                          {QStringLiteral("appWeb"), QStringLiteral("appNative")});

    ModuleDefinition web;
    web.id = QStringLiteral("appWeb");
    web.type = QStringLiteral("web");
    web.name = QStringLiteral("Web 业务");
    web.icon = QStringLiteral("globe-2");

    ModuleDefinition native;
    native.id = QStringLiteral("appNative");
    native.type = QStringLiteral("native");
    native.name = QStringLiteral("本机工具");
    native.icon = QStringLiteral("calculator");
    native.program = QStringLiteral("/opt/star-kylin-demo/not-configured");

    ModuleDefinition kline;
    kline.id = QStringLiteral("appKline");
    kline.type = QStringLiteral("kline");
    kline.name = QStringLiteral("行情中心");
    kline.icon = QStringLiteral("chart-candlestick");

    manifest.modules = {web, native, kline};
    return manifest;
}

} // namespace

class AuthFlowTest final : public QObject {
    Q_OBJECT

private slots:
    void successfulLoginFiltersAuthorizedModules()
    {
        AppController controller(testManifest(), {});

        controller.login(QStringLiteral(" demoA "), QStringLiteral("demo-only"));
        QVERIFY(controller.loginPending());
        QTRY_VERIFY_WITH_TIMEOUT(controller.authenticated(), 1000);

        QCOMPARE(controller.currentUsername(), QStringLiteral("demoA"));
        QCOMPARE(controller.moduleModel()->rowCount(), 2);
        QCOMPARE(controller.moduleModel()->indexOf(QStringLiteral("appNative")), -1);
        QVERIFY(!controller.openModule(QStringLiteral("appNative")));
        QVERIFY(controller.openModule(QStringLiteral("appWeb")));
        QVERIFY(controller.openModule(QStringLiteral("appWeb")));
        QCOMPARE(controller.tabModel()->rowCount(), 2);

        controller.logout();
        QVERIFY(!controller.authenticated());
        QCOMPARE(controller.moduleModel()->rowCount(), 0);
        QCOMPARE(controller.tabModel()->rowCount(), 1);
    }

    void rejectsWrongPassword()
    {
        AppController controller(testManifest(), {});

        controller.login(QStringLiteral("demoA"), QStringLiteral("wrong"));
        QTRY_VERIFY_WITH_TIMEOUT(!controller.loginPending(), 1000);
        QVERIFY(!controller.authenticated());
        QVERIFY(!controller.loginError().isEmpty());
    }

    void secondRoleExposesNativeAndReportsTheFixedPathFailure()
    {
        AppController controller(testManifest(), {});

        controller.login(QStringLiteral("demoB"), QStringLiteral("demo-only"));
        QTRY_VERIFY_WITH_TIMEOUT(controller.authenticated(), 1000);

        QCOMPARE(controller.currentRole(), QStringLiteral("roleB"));
        QCOMPARE(controller.moduleModel()->rowCount(), 2);
        QCOMPARE(controller.moduleModel()->indexOf(QStringLiteral("appKline")), -1);
        QVERIFY(controller.moduleModel()->indexOf(QStringLiteral("appNative")) >= 0);

        QSignalSpy failed(&controller, &AppController::nativeLaunchFailed);
        QVERIFY(controller.openModule(QStringLiteral("appNative")));
        QTRY_COMPARE_WITH_TIMEOUT(failed.count(), 1, 1000);
        const QList<QVariant> arguments = failed.takeFirst();
        QCOMPARE(arguments.at(0).toString(), QStringLiteral("本机工具"));
        QCOMPARE(arguments.at(1).toString(), QStringLiteral("未找到指定应用"));
    }

    void logoutCancelsPendingLogin()
    {
        AppController controller(testManifest(), {});

        controller.login(QStringLiteral("demoA"), QStringLiteral("demo-only"));
        controller.logout();
        QTest::qWait(450);

        QVERIFY(!controller.authenticated());
        QVERIFY(!controller.loginPending());
    }
};

QTEST_GUILESS_MAIN(AuthFlowTest)
#include "test_auth.moc"
