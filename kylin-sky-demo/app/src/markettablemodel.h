#pragma once

#include <QAbstractListModel>
#include <QVariantMap>

struct MarketInstrument {
    QString id;
    QString code;
    QString name;
    QString category;
    QString market;
    double price = 0.0;
    double change = 0.0;
    QString amount;
    QString status;
};

class MarketTableModel final : public QAbstractListModel {
    Q_OBJECT
public:
    enum Role { IdRole = Qt::UserRole + 1, CodeRole, NameRole, CategoryRole, MarketRole, PriceRole,
                ChangeRole, AmountRole, StatusRole, DirectionRole };
    explicit MarketTableModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    void setInstruments(QList<MarketInstrument> instruments);
    void updateInstrument(int row, double price, double change);
    Q_INVOKABLE QVariantMap firstForMarket(const QString &market, const QString &preferredId = QString()) const;
private:
    QList<MarketInstrument> m_instruments;
};
