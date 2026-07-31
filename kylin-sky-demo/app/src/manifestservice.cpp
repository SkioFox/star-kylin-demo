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
    if (error) *error = message;
    return false;
}

bool onlyKeys(const QJsonObject &object, const QSet<QString> &allowed, const QString &context,
              QString *error)
{
    for (auto it = object.constBegin(); it != object.constEnd(); ++it) {
        if (!allowed.contains(it.key()))
            return fail(error, context + QStringLiteral(" 包含未知字段：") + it.key());
    }
    return true;
}

bool requiredString(const QJsonObject &object, const QString &key, const QString &context,
                    QString *output, QString *error)
{
    const QJsonValue value = object.value(key);
    if (!value.isString() || value.toString().trimmed().isEmpty())
        return fail(error, context + QStringLiteral(" 缺少非空字段：") + key);
    *output = value.toString();
    return true;
}

bool stringArray(const QJsonObject &object, const QString &key, const QString &context,
                 QStringList *output, QString *error)
{
    const QJsonValue value = object.value(key);
    if (!value.isArray()) return fail(error, context + QStringLiteral(" 缺少数组字段：") + key);
    QSet<QString> seen;
    for (const QJsonValue &item : value.toArray()) {
        if (!item.isString() || item.toString().isEmpty() || seen.contains(item.toString()))
            return fail(error, context + QStringLiteral(" 的 ") + key + QStringLiteral(" 无效"));
        seen.insert(item.toString());
        output->append(item.toString());
    }
    return true;
}

bool optionalBool(const QJsonObject &object, const QString &key, const QString &context,
                  bool *output, QString *error)
{
    if (!object.contains(key)) return true;
    const QJsonValue value = object.value(key);
    if (!value.isBool()) return fail(error, context + QStringLiteral(" 的 ") + key + QStringLiteral(" 必须是布尔值"));
    *output = value.toBool();
    return true;
}

bool safeQrc(const QString &value)
{
    const QUrl url(value, QUrl::StrictMode);
    if (!url.isValid() || url.scheme() != QStringLiteral("qrc") || !url.host().isEmpty()
        || !url.path().startsWith(QLatin1Char('/'))) return false;
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    const QStringList segments = url.path().split(QLatin1Char('/'), QString::SkipEmptyParts);
#else
    const QStringList segments = url.path().split(QLatin1Char('/'), Qt::SkipEmptyParts);
#endif
    return !segments.contains(QStringLiteral(".")) && !segments.contains(QStringLiteral(".."));
}

QString httpsOrigin(const QString &value)
{
    const QUrl url(value, QUrl::StrictMode);
    if (!url.isValid() || url.scheme() != QStringLiteral("https") || url.host().isEmpty()
        || !url.userInfo().isEmpty()) return {};
    QString origin = QStringLiteral("https://") + url.host(QUrl::FullyEncoded).toLower();
    if (url.port(-1) != -1 && url.port(-1) != 443)
        origin += QLatin1Char(':') + QString::number(url.port());
    return origin;
}

bool validOrigins(const QStringList &origins, const QString &context, QString *error)
{
    for (const QString &origin : origins) {
        const QUrl url(origin, QUrl::StrictMode);
        if (httpsOrigin(origin).isEmpty() || (!url.path().isEmpty() && url.path() != QStringLiteral("/"))
            || url.hasQuery() || url.hasFragment() || origin.contains(QLatin1Char('*')))
            return fail(error, context + QStringLiteral(" 包含非法 HTTPS Origin：") + origin);
    }
    return true;
}

bool parseApprovedPage(const QJsonObject &object, const QString &context,
                       ApprovedPageDefinition *page, QString *error)
{
    if (!page) return fail(error, context + QStringLiteral(" 输出对象不能为空"));
    *page = {};
    if (!onlyKeys(object, {QStringLiteral("id"), QStringLiteral("name"), QStringLiteral("entryUrl"),
                           QStringLiteral("allowedNavigationOrigins"), QStringLiteral("allowedResourceOrigins")},
                  context, error)
        || !requiredString(object, QStringLiteral("id"), context, &page->id, error)
        || !requiredString(object, QStringLiteral("name"), context, &page->name, error)
        || !requiredString(object, QStringLiteral("entryUrl"), context, &page->entryUrl, error)
        || !stringArray(object, QStringLiteral("allowedNavigationOrigins"), context,
                        &page->allowedNavigationOrigins, error)
        || !stringArray(object, QStringLiteral("allowedResourceOrigins"), context,
                        &page->allowedResourceOrigins, error)
        || !validOrigins(page->allowedNavigationOrigins, context, error)
        || !validOrigins(page->allowedResourceOrigins, context, error)) return false;
    const QString origin = httpsOrigin(page->entryUrl);
    if (origin.isEmpty() || !page->allowedNavigationOrigins.contains(origin))
        return fail(error, context + QStringLiteral(" 的 HTTPS 入口未被精确授权"));
    return true;
}
} // namespace

bool ManifestService::load(const QString &resourcePath, ManifestData *manifest, QString *error)
{
    QFile file(resourcePath);
    if (!file.open(QIODevice::ReadOnly))
        return fail(error, QStringLiteral("无法读取只读 Manifest：") + resourcePath);
    return parse(file.readAll(), manifest, error);
}

bool ManifestService::parse(const QByteArray &json, ManifestData *manifest, QString *error)
{
    if (!manifest) return fail(error, QStringLiteral("Manifest 输出对象不能为空"));
    *manifest = {};
    if (error) error->clear();
    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(json, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject())
        return fail(error, QStringLiteral("Manifest JSON 解析失败：") + parseError.errorString());
    const QJsonObject root = document.object();
    if (!onlyKeys(root, {QStringLiteral("schemaVersion"), QStringLiteral("users"),
                         QStringLiteral("roles"), QStringLiteral("modules")},
                  QStringLiteral("Manifest"), error)
        || root.value(QStringLiteral("schemaVersion")).toInt(-1) != 1)
        return fail(error, error && !error->isEmpty() ? *error : QStringLiteral("schemaVersion 必须等于 1"));
    const QJsonObject users = root.value(QStringLiteral("users")).toObject();
    const QJsonObject roles = root.value(QStringLiteral("roles")).toObject();
    const QJsonArray modules = root.value(QStringLiteral("modules")).toArray();
    if (users.isEmpty() || roles.isEmpty() || modules.isEmpty())
        return fail(error, QStringLiteral("users、roles 和 modules 必须非空"));
    for (auto it = users.constBegin(); it != users.constEnd(); ++it) {
        if (it.key().trimmed().isEmpty() || !it.value().isObject())
            return fail(error, QStringLiteral("用户定义无效：") + it.key());
        const QJsonObject object = it.value().toObject();
        UserDefinition user;
        user.username = it.key();
        const QString context = QStringLiteral("用户 ") + it.key();
        if (!onlyKeys(object, {QStringLiteral("password"), QStringLiteral("displayName"), QStringLiteral("role")}, context, error)
            || !requiredString(object, QStringLiteral("password"), context, &user.password, error)
            || !requiredString(object, QStringLiteral("displayName"), context, &user.displayName, error)
            || !requiredString(object, QStringLiteral("role"), context, &user.role, error)) return false;
        manifest->users.insert(user.username, user);
    }
    for (auto it = roles.constBegin(); it != roles.constEnd(); ++it) {
        QStringList ids;
        if (it.key().trimmed().isEmpty() || !it.value().isArray()
            || !stringArray(QJsonObject{{QStringLiteral("ids"), it.value()}}, QStringLiteral("ids"), QStringLiteral("角色 ") + it.key(), &ids, error)) return false;
        manifest->roles.insert(it.key(), ids);
    }
    QSet<QString> moduleIds;
    const QSet<QString> basicTypes = {QStringLiteral("market"), QStringLiteral("network")};
    for (int index = 0; index < modules.size(); ++index) {
        if (!modules.at(index).isObject()) return fail(error, QStringLiteral("模块必须为对象"));
        const QJsonObject object = modules.at(index).toObject();
        ModuleDefinition module;
        const QString context = QStringLiteral("modules[%1]").arg(index);
        if (!requiredString(object, QStringLiteral("id"), context, &module.id, error)
            || !requiredString(object, QStringLiteral("type"), context, &module.type, error)
            || !requiredString(object, QStringLiteral("name"), context, &module.name, error)
            || !requiredString(object, QStringLiteral("description"), context, &module.description, error)
            || !requiredString(object, QStringLiteral("group"), context, &module.group, error)) return false;
        if (moduleIds.contains(module.id)) return fail(error, QStringLiteral("模块 ID 重复：") + module.id);
        moduleIds.insert(module.id);
        const QSet<QString> common = {QStringLiteral("id"), QStringLiteral("type"), QStringLiteral("name"), QStringLiteral("description"), QStringLiteral("group"), QStringLiteral("showInNavigation")};
        if (!optionalBool(object, QStringLiteral("showInNavigation"), context, &module.showInNavigation, error)) return false;
        if (module.type == QStringLiteral("web")) {
            QSet<QString> keys = common;
            keys.unite({QStringLiteral("entryUrl"), QStringLiteral("allowedLocalPrefixes"), QStringLiteral("allowedNavigationOrigins"), QStringLiteral("allowedResourceOrigins"), QStringLiteral("approvedPages")});
            if (!onlyKeys(object, keys, context, error)
                || !requiredString(object, QStringLiteral("entryUrl"), context, &module.entryUrl, error)
                || !stringArray(object, QStringLiteral("allowedLocalPrefixes"), context, &module.allowedLocalPrefixes, error)
                || !stringArray(object, QStringLiteral("allowedNavigationOrigins"), context, &module.allowedNavigationOrigins, error)
                || !stringArray(object, QStringLiteral("allowedResourceOrigins"), context, &module.allowedResourceOrigins, error)
                || !validOrigins(module.allowedNavigationOrigins, context, error)
                || !validOrigins(module.allowedResourceOrigins, context, error)) return false;
            if (safeQrc(module.entryUrl)) {
                bool allowed = false;
                for (const QString &prefix : module.allowedLocalPrefixes)
                    allowed = allowed || (safeQrc(prefix) && prefix.endsWith(QLatin1Char('/')) && module.entryUrl.startsWith(prefix));
                if (!allowed) return fail(error, context + QStringLiteral(" 的 qrc 入口不在允许前缀内"));
            } else if (httpsOrigin(module.entryUrl).isEmpty() || !module.allowedLocalPrefixes.isEmpty()
                       || !module.allowedNavigationOrigins.contains(httpsOrigin(module.entryUrl))) {
                return fail(error, context + QStringLiteral(" 的 HTTPS 入口未被精确授权"));
            }
            if (object.contains(QStringLiteral("approvedPages"))) {
                const QJsonValue pages = object.value(QStringLiteral("approvedPages"));
                if (!pages.isArray() || pages.toArray().isEmpty())
                    return fail(error, context + QStringLiteral(" 的 approvedPages 无效"));
                QSet<QString> pageIds;
                for (const QJsonValue &value : pages.toArray()) {
                    if (!value.isObject()) return fail(error, context + QStringLiteral(" 的 approvedPages 项无效"));
                    ApprovedPageDefinition page;
                    if (!parseApprovedPage(value.toObject(), context + QStringLiteral(" 的 approvedPages"), &page, error)) return false;
                    if (pageIds.contains(page.id)) return fail(error, context + QStringLiteral(" 的 approvedPages ID 重复：") + page.id);
                    pageIds.insert(page.id);
                    for (const QString &origin : page.allowedNavigationOrigins)
                        if (!module.allowedNavigationOrigins.contains(origin)) return fail(error, context + QStringLiteral(" 的 approvedPages 导航来源未在模块范围内授权"));
                    for (const QString &origin : page.allowedResourceOrigins)
                        if (!module.allowedResourceOrigins.contains(origin)) return fail(error, context + QStringLiteral(" 的 approvedPages 资源来源未在模块范围内授权"));
                    module.approvedPages.append(page);
                }
            }
        } else if (module.type == QStringLiteral("native")) {
            QSet<QString> keys = common;
            keys.unite({QStringLiteral("program"), QStringLiteral("args")});
            if (!onlyKeys(object, keys, context, error)
                || !requiredString(object, QStringLiteral("program"), context, &module.program, error)
                || !stringArray(object, QStringLiteral("args"), context, &module.args, error)
                || !QDir::isAbsolutePath(module.program) || module.args.size() > 5) return fail(error, context + QStringLiteral(" 的原生启动配置无效"));
            for (const QString &arg : module.args)
                if (arg.size() > 256 || arg.contains(QChar::Null)) return fail(error, context + QStringLiteral(" 的参数无效"));
        } else if (basicTypes.contains(module.type)) {
            if (!onlyKeys(object, common, context, error)) return false;
        } else {
            return fail(error, QStringLiteral("未知模块类型：") + module.type);
        }
        manifest->modules.append(module);
    }
    for (auto it = manifest->roles.constBegin(); it != manifest->roles.constEnd(); ++it)
        for (const QString &id : it.value())
            if (!moduleIds.contains(id)) return fail(error, QStringLiteral("角色引用不存在模块：") + id);
    for (auto it = manifest->users.constBegin(); it != manifest->users.constEnd(); ++it)
        if (!manifest->roles.contains(it->role)) return fail(error, QStringLiteral("用户角色不存在：") + it->role);
    return true;
}
