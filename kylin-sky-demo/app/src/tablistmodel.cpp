#include "tablistmodel.h"

TabListModel::TabListModel(QObject *parent) : QAbstractListModel(parent) { reset(); }
int TabListModel::rowCount(const QModelIndex &parent) const { return parent.isValid() ? 0 : m_tabs.size(); }
QVariant TabListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_tabs.size()) return {};
    const Tab &tab = m_tabs.at(index.row());
    switch (role) { case IdRole: return tab.id; case NameRole: return tab.name; case ClosableRole: return tab.closable; case ActiveRole: return index.row() == m_activeIndex; default: return {}; }
}
QHash<int, QByteArray> TabListModel::roleNames() const { return {{IdRole, "moduleId"}, {NameRole, "title"}, {ClosableRole, "closable"}, {ActiveRole, "active"}}; }
QString TabListModel::activeId() const { return m_tabs.isEmpty() ? QString() : m_tabs.at(m_activeIndex).id; }
QString TabListModel::activeName() const { return m_tabs.isEmpty() ? QString() : m_tabs.at(m_activeIndex).name; }
void TabListModel::reset() { beginResetModel(); m_tabs = {{QStringLiteral("workbench"), QStringLiteral("工作台"), false}}; m_activeIndex = 0; endResetModel(); emit activeIdChanged(); }
void TabListModel::openModule(const ModuleDefinition &module) { const int existing = indexOf(module.id); if (existing >= 0) { setActiveIndex(existing); return; } const int index = m_tabs.size(); beginInsertRows({}, index, index); m_tabs.append({module.id, module.name, true}); endInsertRows(); setActiveIndex(index); }
bool TabListModel::activate(const QString &id) { const int index = indexOf(id); if (index < 0) return false; setActiveIndex(index); return true; }
bool TabListModel::close(const QString &id) { const int index = indexOf(id); if (index <= 0 || !m_tabs.at(index).closable) return false; const bool active = index == m_activeIndex; beginRemoveRows({}, index, index); m_tabs.removeAt(index); endRemoveRows(); if (active) { m_activeIndex = index - 1; emit activeIdChanged(); } else if (index < m_activeIndex) --m_activeIndex; if (!m_tabs.isEmpty()) emit dataChanged(this->index(0), this->index(m_tabs.size() - 1), {ActiveRole}); return true; }
int TabListModel::indexOf(const QString &id) const { for (int index = 0; index < m_tabs.size(); ++index) if (m_tabs.at(index).id == id) return index; return -1; }
void TabListModel::setActiveIndex(int index) { if (index < 0 || index >= m_tabs.size() || index == m_activeIndex) return; const int previous = m_activeIndex; m_activeIndex = index; emit dataChanged(this->index(previous), this->index(previous), {ActiveRole}); emit dataChanged(this->index(index), this->index(index), {ActiveRole}); emit activeIdChanged(); }
