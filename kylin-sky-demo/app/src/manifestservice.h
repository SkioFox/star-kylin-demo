#pragma once

#include <QHash>
#include <QList>
#include <QString>
#include <QStringList>

struct UserDefinition {
    QString username;
    QString password;
    QString displayName;
    QString role;
};

struct ModuleDefinition {
    QString id;
    QString type;
    QString name;
    QString description;
    QString group;
    QString entryUrl;
    QStringList allowedLocalPrefixes;
    QStringList allowedNavigationOrigins;
    QStringList allowedResourceOrigins;
    QString program;
    QStringList args;
};

struct ManifestData {
    QHash<QString, UserDefinition> users;
    QHash<QString, QStringList> roles;
    QList<ModuleDefinition> modules;
};

class ManifestService final {
public:
    static bool load(const QString &resourcePath, ManifestData *manifest, QString *error);
    static bool parse(const QByteArray &json, ManifestData *manifest, QString *error);
};
