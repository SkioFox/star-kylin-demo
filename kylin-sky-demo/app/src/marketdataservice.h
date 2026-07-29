#pragma once

#include "markettablemodel.h"

#include <QObject>

class QTimer;

class MarketDataService final : public QObject {
    Q_OBJECT
    Q_PROPERTY(MarketTableModel *model READ model CONSTANT)
    Q_PROPERTY(QString error READ error NOTIFY stateChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY stateChanged)
public:
    explicit MarketDataService(QObject *parent = nullptr);
    MarketTableModel *model();
    QString error() const;
    bool ready() const;
    Q_INVOKABLE void reload();
signals:
    void stateChanged();
private:
    bool load();
    void startUpdates();
    MarketTableModel m_model;
    QTimer *m_timer = nullptr;
    QString m_error;
    int m_tick = 0;
};
