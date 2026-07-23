#include "nativelauncher.h"

#include <QtTest>

class NativeLauncherTest final : public QObject {
    Q_OBJECT

private slots:
    void startsOnlyAnAbsoluteExecutable()
    {
        ModuleDefinition module;
        module.type = QStringLiteral("native");
        module.program = QStringLiteral("/bin/true");

        const NativeLaunchResult result = NativeLauncher::launch(module);
        QCOMPARE(result.status, NativeLaunchResult::Status::Started);
        QVERIFY(result.pid > 0);
    }

    void rejectsMissingExecutable()
    {
        ModuleDefinition module;
        module.type = QStringLiteral("native");
        module.program = QStringLiteral("/opt/star-kylin-demo/does-not-exist");

        QCOMPARE(NativeLauncher::launch(module).status, NativeLaunchResult::Status::Missing);
    }

    void rejectsRelativePathAndUnsafeArguments()
    {
        ModuleDefinition module;
        module.type = QStringLiteral("native");
        module.program = QStringLiteral("true");
        QCOMPARE(NativeLauncher::launch(module).status,
                 NativeLaunchResult::Status::InvalidConfiguration);

        module.program = QStringLiteral("/bin/true");
        module.args = QStringList{QString(257, QLatin1Char('a'))};
        QCOMPARE(NativeLauncher::launch(module).status,
                 NativeLaunchResult::Status::InvalidConfiguration);

        module.args = QStringList{QStringLiteral("safe"), QString(QChar::Null)};
        QCOMPARE(NativeLauncher::launch(module).status,
                 NativeLaunchResult::Status::InvalidConfiguration);
    }
};

QTEST_APPLESS_MAIN(NativeLauncherTest)
#include "test_native.moc"
