#include "nativelauncher.h"

#include <QFileInfo>
#include <QProcess>

NativeLaunchResult NativeLauncher::launch(const ModuleDefinition &module)
{
    if (module.type != QStringLiteral("native") || module.program.isEmpty()
        || !QFileInfo(module.program).isAbsolute() || module.args.size() > 5) {
        return {NativeLaunchResult::Status::InvalidConfiguration, -1};
    }
    for (const QString &argument : module.args) {
        if (argument.size() > 256 || argument.contains(QChar::Null)) {
            return {NativeLaunchResult::Status::InvalidConfiguration, -1};
        }
    }

    const QFileInfo executable(module.program);
    if (!executable.exists() || !executable.isFile() || !executable.isExecutable()) {
        return {NativeLaunchResult::Status::Missing, -1};
    }

    qint64 pid = -1;
    const bool started = QProcess::startDetached(executable.absoluteFilePath(), module.args,
                                                 executable.absolutePath(), &pid);
    return started && pid > 0 ? NativeLaunchResult{NativeLaunchResult::Status::Started, pid}
                              : NativeLaunchResult{NativeLaunchResult::Status::Failed, -1};
}
