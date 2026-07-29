#pragma once

#include "manifestservice.h"

#include <QAbstractListModel>

class TabListModel final : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(QString activeId READ activeId NOTIFY activeIdChanged)
    Q_PROPERTY(QString activeName READ activeName NOTIFY activeIdChanged)
public:
    enum Role { IdRole = Qt::UserRole + 1, NameRole, ClosableRole, ActiveRole };
    explicit TabListModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    QString activeId() const;
    QString activeName() const;
    void reset();
    void openModule(const ModuleDefinition &module);
    Q_INVOKABLE bool activate(const QString &id);
    Q_INVOKABLE bool close(const QString &id);
signals:
    void activeIdChanged();
private:
    struct Tab { QString id; QString name; bool closable = true; };
    int indexOf(const QString &id) const;
    void setActiveIndex(int index);
    QList<Tab> m_tabs;
    int m_activeIndex = 0;
};
