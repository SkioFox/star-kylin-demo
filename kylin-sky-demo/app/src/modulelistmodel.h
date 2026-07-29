#pragma once

#include "manifestservice.h"

#include <QAbstractListModel>

class ModuleListModel final : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Role { IdRole = Qt::UserRole + 1, TypeRole, NameRole, DescriptionRole, GroupRole };
    explicit ModuleListModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void setModules(const QList<ModuleDefinition> &modules);
    const ModuleDefinition *find(const QString &id) const;
signals:
    void countChanged();
private:
    QList<ModuleDefinition> m_modules;
};
