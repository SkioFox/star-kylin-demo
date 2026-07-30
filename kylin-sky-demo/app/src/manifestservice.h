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

struct ApprovedPageDefinition {
    QString id;
    QString name;
    QString entryUrl;
    QStringList allowedNavigationOrigins;
    QStringList allowedResourceOrigins;
};

struct ModuleDefinition {
    QString id;
    QString type;
    QString name;
    QString description;
    QString group;
    bool showInNavigation = true;
    QString entryUrl;
    QStringList allowedLocalPrefixes;
    QStringList allowedNavigationOrigins;
    QStringList allowedResourceOrigins;
    QList<ApprovedPageDefinition> approvedPages;
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
