#include "nativelauncher.h"

#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    ModuleDefinition wrongType;
    wrongType.type = QStringLiteral("web");
    wrongType.program = QStringLiteral("/usr/bin/true");
    ModuleDefinition relative;
    relative.type = QStringLiteral("native");
    relative.program = QStringLiteral("bin/true");
    ModuleDefinition overflow;
    overflow.type = QStringLiteral("native");
    overflow.program = QStringLiteral("/usr/bin/true");
    overflow.args = QStringList() << "1" << "2" << "3" << "4" << "5" << "6";
    ModuleDefinition missing;
    missing.type = QStringLiteral("native");
    missing.program = QStringLiteral("/opt/kylin-sky-demo/not-installed");
    const bool valid = NativeLauncher::launch(wrongType).contains(QStringLiteral("安全检查"))
                       && NativeLauncher::launch(relative).contains(QStringLiteral("安全检查"))
                       && NativeLauncher::launch(overflow).contains(QStringLiteral("安全检查"))
                       && NativeLauncher::launch(missing).contains(QStringLiteral("未找到"));
    if (!valid) qCritical() << "native launcher boundary regression";
    return valid ? 0 : 1;
}
