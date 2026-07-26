#include "manifestservice.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSet>
#include <QUrl>

namespace {

bool fail(QString *error, const QString &message)
{
    if (error) {
        *error = message;
    }
    return false;
}

bool hasOnlyKeys(const QJsonObject &object, const QSet<QString> &allowed, const QString &context,
                 QString *error)
{
    for (auto it = object.constBegin(); it != object.constEnd(); ++it) {
        if (!allowed.contains(it.key())) {
            return fail(error, context + QStringLiteral(" 包含未知字段：") + it.key());
        }
    }
    return true;
}

bool readRequiredString(const QJsonObject &object, const QString &key, const QString &context,
                        QString *value, QString *error)
{
    const QJsonValue jsonValue = object.value(key);
    if (!jsonValue.isString() || jsonValue.toString().trimmed().isEmpty()) {
        return fail(error, context + QStringLiteral(" 缺少非空字符串字段：") + key);
    }
    *value = jsonValue.toString();
    return true;
}

bool readStringArray(const QJsonObject &object, const QString &key, const QString &context,
                     QStringList *values, QString *error)
{
    const QJsonValue jsonValue = object.value(key);
    if (!jsonValue.isArray()) {
        return fail(error, context + QStringLiteral(" 缺少数组字段：") + key);
    }

    QSet<QString> seen;
    for (const QJsonValue &item : jsonValue.toArray()) {
        if (!item.isString() || item.toString().isEmpty()) {
            return fail(error, context + QStringLiteral(" 的 ") + key
                                   + QStringLiteral(" 只能包含非空字符串"));
        }
        if (seen.contains(item.toString())) {
            return fail(error, context + QStringLiteral(" 的 ") + key
                                   + QStringLiteral(" 包含重复值：") + item.toString());
        }
        seen.insert(item.toString());
        values->append(item.toString());
    }
    return true;
}

bool isSafeQrcUrl(const QString &value)
{
    const QUrl url(value);
    if (!url.isValid() || url.scheme() != QStringLiteral("qrc")
        || !url.path().startsWith(QLatin1Char('/'))) {
        return false;
    }
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    const QStringList segments = url.path().split(QLatin1Char('/'), QString::SkipEmptyParts);
#else
    const QStringList segments = url.path().split(QLatin1Char('/'), Qt::SkipEmptyParts);
#endif
    return !segments.contains(QStringLiteral("..")) && !segments.contains(QStringLiteral("."));
}

QString httpsOrigin(const QString &value)
{
    const QUrl url(value);
    if (!url.isValid() || url.scheme() != QStringLiteral("https") || url.host().isEmpty()
        || !url.userInfo().isEmpty()) {
        return {};
    }

    QString origin = QStringLiteral("https://") + url.host(QUrl::FullyEncoded).toLower();
    if (url.port(-1) != -1 && url.port(-1) != 443) {
        origin += QLatin1Char(':') + QString::number(url.port());
    }
    return origin;
}

bool validateOriginList(const QStringList &origins, const QString &context, QString *error)
{
    for (const QString &origin : origins) {
        const QUrl url(origin);
        if (httpsOrigin(origin).isEmpty() || (!url.path().isEmpty() && url.path() != QStringLiteral("/"))
            || url.hasQuery() || url.hasFragment() || origin.contains(QLatin1Char('*'))) {
            return fail(error, context + QStringLiteral(" 包含非法 HTTPS Origin：") + origin);
        }
    }
    return true;
}

bool parseCommonModule(const QJsonObject &object, int index, ModuleDefinition *module, QString *error)
{
    const QString context = QStringLiteral("modules[%1]").arg(index);
    return readRequiredString(object, QStringLiteral("id"), context, &module->id, error)
        && readRequiredString(object, QStringLiteral("type"), context, &module->type, error)
        && readRequiredString(object, QStringLiteral("name"), context, &module->name, error)
        && readRequiredString(object, QStringLiteral("description"), context, &module->description, error)
        && readRequiredString(object, QStringLiteral("icon"), context, &module->icon, error)
        && readRequiredString(object, QStringLiteral("status"), context, &module->status, error)
        && readRequiredString(object, QStringLiteral("accent"), context, &module->accent, error)
        && readRequiredString(object, QStringLiteral("tint"), context, &module->tint, error);
}

bool validateWebModule(const QJsonObject &object, int index, ModuleDefinition *module, QString *error)
{
    const QString context = QStringLiteral("Web 模块 %1").arg(module->id);
    const QSet<QString> allowed = {
        QStringLiteral("id"), QStringLiteral("type"), QStringLiteral("name"),
        QStringLiteral("description"), QStringLiteral("icon"), QStringLiteral("status"),
        QStringLiteral("accent"), QStringLiteral("tint"), QStringLiteral("entryUrl"),
        QStringLiteral("allowedLocalPrefixes"), QStringLiteral("allowedNavigationOrigins"),
        QStringLiteral("allowedResourceOrigins")};
    if (!hasOnlyKeys(object, allowed, context, error)
        || !readRequiredString(object, QStringLiteral("entryUrl"), context, &module->entryUrl, error)
        || !readStringArray(object, QStringLiteral("allowedLocalPrefixes"), context,
                            &module->allowedLocalPrefixes, error)
        || !readStringArray(object, QStringLiteral("allowedNavigationOrigins"), context,
                            &module->allowedNavigationOrigins, error)
        || !readStringArray(object, QStringLiteral("allowedResourceOrigins"), context,
                            &module->allowedResourceOrigins, error)) {
        return false;
    }

    if (!validateOriginList(module->allowedNavigationOrigins, context, error)
        || !validateOriginList(module->allowedResourceOrigins, context, error)) {
        return false;
    }

    if (isSafeQrcUrl(module->entryUrl)) {
        for (const QString &prefix : module->allowedLocalPrefixes) {
            if (!isSafeQrcUrl(prefix) || !prefix.endsWith(QLatin1Char('/'))) {
                return fail(error, context + QStringLiteral(" 包含非法 qrc 前缀：") + prefix);
            }
            if (module->entryUrl.startsWith(prefix)) {
                return true;
            }
        }
        return fail(error, context + QStringLiteral(" 的 qrc 入口不在允许前缀内"));
    }

    const QString entryOrigin = httpsOrigin(module->entryUrl);
    if (entryOrigin.isEmpty() || !module->allowedLocalPrefixes.isEmpty()
        || !module->allowedNavigationOrigins.contains(entryOrigin)) {
        return fail(error, context + QStringLiteral(" 的 HTTPS 入口未被精确导航 Origin 授权"));
    }
    Q_UNUSED(index)
    return true;
}

bool validateNativeModule(const QJsonObject &object, ModuleDefinition *module, QString *error)
{
    const QString context = QStringLiteral("Native 模块 ") + module->id;
    const QSet<QString> allowed = {
        QStringLiteral("id"), QStringLiteral("type"), QStringLiteral("name"),
        QStringLiteral("description"), QStringLiteral("icon"), QStringLiteral("status"),
        QStringLiteral("accent"), QStringLiteral("tint"), QStringLiteral("program"),
        QStringLiteral("args")};
    if (!hasOnlyKeys(object, allowed, context, error)
        || !readRequiredString(object, QStringLiteral("program"), context, &module->program, error)
        || !readStringArray(object, QStringLiteral("args"), context, &module->args, error)) {
        return false;
    }
    if (!QDir::isAbsolutePath(module->program)) {
        return fail(error, context + QStringLiteral(" 的 program 必须是绝对路径"));
    }
    if (module->args.size() > 5) {
        return fail(error, context + QStringLiteral(" 的 args 不能超过 5 项"));
    }
    for (const QString &arg : module->args) {
        if (arg.size() > 256 || arg.contains(QChar::Null)) {
            return fail(error, context + QStringLiteral(" 的 args 超出长度或包含 NUL"));
        }
    }
    return true;
}

bool validateKlineModule(const QJsonObject &object, ModuleDefinition *module, QString *error)
{
    const QString context = QStringLiteral("Kline 模块 ") + module->id;
    const QSet<QString> allowed = {
        QStringLiteral("id"), QStringLiteral("type"), QStringLiteral("name"),
        QStringLiteral("description"), QStringLiteral("icon"), QStringLiteral("status"),
        QStringLiteral("accent"), QStringLiteral("tint"), QStringLiteral("entryUrl")};
    if (!hasOnlyKeys(object, allowed, context, error)
        || !readRequiredString(object, QStringLiteral("entryUrl"), context, &module->entryUrl, error)) {
        return false;
    }
    if (!isSafeQrcUrl(module->entryUrl)
        || !module->entryUrl.startsWith(QStringLiteral("qrc:/web-kline/"))) {
        return fail(error, context + QStringLiteral(" 的入口必须位于 qrc:/web-kline/"));
    }
    return true;
}

} // namespace

const ModuleDefinition *ManifestData::findModule(const QString &id) const
{
    for (const ModuleDefinition &module : modules) {
        if (module.id == id) {
            return &module;
        }
    }
    return nullptr;
}

bool ManifestService::load(const QString &resourcePath, ManifestData *manifest, QString *error)
{
    QFile file(resourcePath);
    if (!file.open(QIODevice::ReadOnly)) {
        return fail(error, QStringLiteral("无法读取只读 Manifest：") + resourcePath);
    }
    return parse(file.readAll(), manifest, error);
}

bool ManifestService::parse(const QByteArray &json, ManifestData *manifest, QString *error)
{
    if (!manifest) {
        return fail(error, QStringLiteral("Manifest 输出对象不能为空"));
    }
    *manifest = {};
    if (error) {
        error->clear();
    }

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(json, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) {
        return fail(error, QStringLiteral("Manifest JSON 解析失败：") + parseError.errorString());
    }

    const QJsonObject root = document.object();
    const QSet<QString> rootKeys = {QStringLiteral("schemaVersion"), QStringLiteral("users"),
                                    QStringLiteral("roles"), QStringLiteral("modules")};
    if (!hasOnlyKeys(root, rootKeys, QStringLiteral("Manifest"), error)
        || root.value(QStringLiteral("schemaVersion")).toInt(-1) != 1) {
        return fail(error, error && !error->isEmpty() ? *error
                                                       : QStringLiteral("schemaVersion 必须等于 1"));
    }
    manifest->schemaVersion = 1;

    const QJsonValue usersValue = root.value(QStringLiteral("users"));
    const QJsonValue rolesValue = root.value(QStringLiteral("roles"));
    const QJsonValue modulesValue = root.value(QStringLiteral("modules"));
    if (!usersValue.isObject() || usersValue.toObject().isEmpty() || !rolesValue.isObject()
        || rolesValue.toObject().isEmpty() || !modulesValue.isArray()
        || modulesValue.toArray().isEmpty()) {
        return fail(error, QStringLiteral("users、roles 和 modules 必须存在且非空"));
    }

    const QSet<QString> userKeys = {QStringLiteral("password"), QStringLiteral("displayName"),
                                    QStringLiteral("role")};
    const QJsonObject users = usersValue.toObject();
    for (auto it = users.constBegin(); it != users.constEnd(); ++it) {
        const QString username = it.key();
        if (username.trimmed().isEmpty() || !it.value().isObject()) {
            return fail(error, QStringLiteral("用户定义无效：") + username);
        }
        const QJsonObject object = it.value().toObject();
        const QString context = QStringLiteral("用户 ") + username;
        UserDefinition user;
        user.username = username;
        if (!hasOnlyKeys(object, userKeys, context, error)
            || !readRequiredString(object, QStringLiteral("password"), context, &user.password, error)
            || !readRequiredString(object, QStringLiteral("displayName"), context,
                                   &user.displayName, error)
            || !readRequiredString(object, QStringLiteral("role"), context, &user.role, error)) {
            return false;
        }
        manifest->users.insert(username, user);
    }

    const QJsonObject roles = rolesValue.toObject();
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        if (it.key().trimmed().isEmpty() || !it.value().isArray()) {
            return fail(error, QStringLiteral("角色定义无效：") + it.key());
        }
        QStringList moduleIds;
        QSet<QString> seen;
        for (const QJsonValue &moduleId : it.value().toArray()) {
            if (!moduleId.isString() || moduleId.toString().isEmpty()
                || seen.contains(moduleId.toString())) {
                return fail(error, QStringLiteral("角色模块引用无效：") + it.key());
            }
            seen.insert(moduleId.toString());
            moduleIds.append(moduleId.toString());
        }
        manifest->roles.insert(it.key(), moduleIds);
    }

    QSet<QString> moduleIds;
    const QJsonArray modules = modulesValue.toArray();
    for (int index = 0; index < modules.size(); ++index) {
        if (!modules.at(index).isObject()) {
            return fail(error, QStringLiteral("modules[%1] 必须是对象").arg(index));
        }
        const QJsonObject object = modules.at(index).toObject();
        ModuleDefinition module;
        if (!parseCommonModule(object, index, &module, error)) {
            return false;
        }
        if (moduleIds.contains(module.id)) {
            return fail(error, QStringLiteral("模块 ID 重复：") + module.id);
        }
        moduleIds.insert(module.id);

        if (module.type == QStringLiteral("web")) {
            if (!validateWebModule(object, index, &module, error)) {
                return false;
            }
        } else if (module.type == QStringLiteral("native")) {
            if (!validateNativeModule(object, &module, error)) {
                return false;
            }
        } else if (module.type == QStringLiteral("kline")) {
            if (!validateKlineModule(object, &module, error)) {
                return false;
            }
        } else {
            return fail(error, QStringLiteral("未知模块类型：") + module.type);
        }
        manifest->modules.append(module);
    }

    for (auto it = manifest->roles.constBegin(); it != manifest->roles.constEnd(); ++it) {
        for (const QString &moduleId : it.value()) {
            if (!moduleIds.contains(moduleId)) {
                return fail(error, QStringLiteral("角色 ") + it.key()
                                       + QStringLiteral(" 引用了不存在的模块：") + moduleId);
            }
        }
    }
    for (auto it = manifest->users.constBegin(); it != manifest->users.constEnd(); ++it) {
        if (!manifest->roles.contains(it.value().role)) {
            return fail(error, QStringLiteral("用户 ") + it.key()
                                   + QStringLiteral(" 引用了不存在的角色：") + it.value().role);
        }
    }

    if (error) {
        error->clear();
    }
    return true;
}
