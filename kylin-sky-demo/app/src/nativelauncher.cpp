#include "nativelauncher.h"

#include <QFileInfo>
#include <QProcess>

QString NativeLauncher::launch(const ModuleDefinition &module)
{
    if (module.type != QStringLiteral("native") || !QFileInfo(module.program).isAbsolute()
        || module.args.size() > 5) return QStringLiteral("启动配置未通过安全检查。");
    for (const QString &arg : module.args)
        if (arg.size() > 256 || arg.contains(QChar::Null)) return QStringLiteral("启动参数未通过安全检查。");
    const QFileInfo executable(module.program);
    if (!executable.exists() || !executable.isExecutable()) return QStringLiteral("未找到清单中的固定本机应用。");
    return QProcess::startDetached(module.program, module.args)
               ? QStringLiteral("已请求启动，应用将在独立系统窗口打开。")
               : QStringLiteral("指定应用未能启动，请检查本机应用状态。");
}
