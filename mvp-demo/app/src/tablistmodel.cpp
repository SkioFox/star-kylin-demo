#include "tablistmodel.h"

TabListModel::TabListModel(QObject *parent)
    : QAbstractListModel(parent)
{
    reset();
}

int TabListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_tabs.size();
}

QVariant TabListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tabs.size()) {
        return {};
    }
    const Tab &tab = m_tabs.at(index.row());
    switch (role) {
    case IdRole:
        return tab.id;
    case NameRole:
        return tab.name;
    case IconRole:
        return tab.icon;
    case ClosableRole:
        return tab.closable;
    case ActiveRole:
        return index.row() == m_activeIndex;
    default:
        return {};
    }
}

QHash<int, QByteArray> TabListModel::roleNames() const
{
    return {{IdRole, "id"}, {NameRole, "name"}, {IconRole, "iconName"},
            {ClosableRole, "closable"}, {ActiveRole, "active"}};
}

QString TabListModel::activeId() const
{
    return m_tabs.isEmpty() ? QString() : m_tabs.at(m_activeIndex).id;
}

void TabListModel::reset()
{
    beginResetModel();
    m_tabs = {{QStringLiteral("workbench"), QStringLiteral("工作台"),
               QStringLiteral("layout-dashboard"), false}};
    m_activeIndex = 0;
    endResetModel();
    emit countChanged();
    emit activeIdChanged();
}

void TabListModel::openModule(const ModuleDefinition &module)
{
    const int existing = indexOf(module.id);
    if (existing >= 0) {
        setActiveIndex(existing);
        return;
    }

    const int newIndex = m_tabs.size();
    beginInsertRows(QModelIndex(), newIndex, newIndex);
    m_tabs.append({module.id, module.name, module.icon, true});
    endInsertRows();
    emit countChanged();
    setActiveIndex(newIndex);
}

bool TabListModel::activate(const QString &id)
{
    const int index = indexOf(id);
    if (index < 0) {
        return false;
    }
    setActiveIndex(index);
    return true;
}

bool TabListModel::close(const QString &id)
{
    const int index = indexOf(id);
    if (index <= 0 || !m_tabs.at(index).closable) {
        return false;
    }

    const bool closingActive = index == m_activeIndex;
    beginRemoveRows(QModelIndex(), index, index);
    m_tabs.removeAt(index);
    endRemoveRows();
    emit countChanged();

    if (closingActive) {
        m_activeIndex = qMax(0, index - 1);
        emit activeIdChanged();
    } else if (index < m_activeIndex) {
        --m_activeIndex;
    }
    if (!m_tabs.isEmpty()) {
        emit dataChanged(this->index(0), this->index(m_tabs.size() - 1), {ActiveRole});
    }
    return true;
}

int TabListModel::indexOf(const QString &id) const
{
    for (int index = 0; index < m_tabs.size(); ++index) {
        if (m_tabs.at(index).id == id) {
            return index;
        }
    }
    return -1;
}

void TabListModel::setActiveIndex(int index)
{
    if (index < 0 || index >= m_tabs.size() || index == m_activeIndex) {
        return;
    }
    const int previous = m_activeIndex;
    m_activeIndex = index;
    emit dataChanged(this->index(previous), this->index(previous), {ActiveRole});
    emit dataChanged(this->index(m_activeIndex), this->index(m_activeIndex), {ActiveRole});
    emit activeIdChanged();
}
