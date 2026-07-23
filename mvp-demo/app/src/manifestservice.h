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
    QString icon;
    QString status;
    QString accent;
    QString tint;
    QString entryUrl;
    QStringList allowedLocalPrefixes;
    QStringList allowedNavigationOrigins;
    QStringList allowedResourceOrigins;
    QString program;
    QStringList args;
};

struct ManifestData {
    int schemaVersion = 0;
    QHash<QString, UserDefinition> users;
    QHash<QString, QStringList> roles;
    QList<ModuleDefinition> modules;

    const ModuleDefinition *findModule(const QString &id) const;
};

class ManifestService final {
public:
    static bool load(const QString &resourcePath, ManifestData *manifest, QString *error);
    static bool parse(const QByteArray &json, ManifestData *manifest, QString *error);
};
