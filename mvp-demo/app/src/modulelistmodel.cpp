#include "modulelistmodel.h"

ModuleListModel::ModuleListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int ModuleListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_modules.size();
}

QVariant ModuleListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_modules.size()) {
        return {};
    }
    const ModuleDefinition &module = m_modules.at(index.row());
    switch (role) {
    case IdRole:
        return module.id;
    case TypeRole:
        return module.type;
    case NameRole:
        return module.name;
    case DescriptionRole:
        return module.description;
    case IconRole:
        return module.icon;
    case StatusRole:
        return module.status;
    case AccentRole:
        return module.accent;
    case TintRole:
        return module.tint;
    default:
        return {};
    }
}

QHash<int, QByteArray> ModuleListModel::roleNames() const
{
    return {{IdRole, "id"},           {TypeRole, "type"},
            {NameRole, "name"},       {DescriptionRole, "description"},
            {IconRole, "iconName"},   {StatusRole, "status"},
            {AccentRole, "accent"},   {TintRole, "tint"}};
}

void ModuleListModel::setModules(const QList<ModuleDefinition> &modules)
{
    beginResetModel();
    m_modules = modules;
    endResetModel();
    emit countChanged();
}

const ModuleDefinition *ModuleListModel::find(const QString &id) const
{
    for (const ModuleDefinition &module : m_modules) {
        if (module.id == id) {
            return &module;
        }
    }
    return nullptr;
}

int ModuleListModel::indexOf(const QString &id) const
{
    for (int index = 0; index < m_modules.size(); ++index) {
        if (m_modules.at(index).id == id) {
            return index;
        }
    }
    return -1;
}
