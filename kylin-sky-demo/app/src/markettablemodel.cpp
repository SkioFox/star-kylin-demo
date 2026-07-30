#include "markettablemodel.h"

MarketTableModel::MarketTableModel(QObject *parent) : QAbstractListModel(parent) {}
int MarketTableModel::rowCount(const QModelIndex &parent) const { return parent.isValid() ? 0 : m_instruments.size(); }
QVariant MarketTableModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_instruments.size()) return {};
    const MarketInstrument &item = m_instruments.at(index.row());
    switch (role) {
    case IdRole: return item.id; case CodeRole: return item.code; case NameRole: return item.name;
    case CategoryRole: return item.category; case MarketRole: return item.market; case PriceRole: return item.price;
    case ChangeRole: return item.change; case AmountRole: return item.amount; case StatusRole: return item.status;
    case DirectionRole: return item.change >= 0.0 ? QStringLiteral("up") : QStringLiteral("down");
    default: return {};
    }
}
QHash<int, QByteArray> MarketTableModel::roleNames() const
{
    return {{IdRole, "instrumentId"}, {CodeRole, "code"}, {NameRole, "name"},
            {CategoryRole, "category"}, {MarketRole, "market"}, {PriceRole, "price"},
            {ChangeRole, "change"}, {AmountRole, "amount"}, {StatusRole, "status"}, {DirectionRole, "direction"}};
}
void MarketTableModel::setInstruments(QList<MarketInstrument> instruments)
{
    beginResetModel(); m_instruments = std::move(instruments); endResetModel();
}
void MarketTableModel::updateInstrument(int row, double price, double change)
{
    if (row < 0 || row >= m_instruments.size()) return;
    m_instruments[row].price = price;
    m_instruments[row].change = change;
    emit dataChanged(index(row), index(row), {PriceRole, ChangeRole, DirectionRole});
}
QVariantMap MarketTableModel::firstForMarket(const QString &market, const QString &preferredId) const
{
    if (!preferredId.isEmpty()) {
        for (const MarketInstrument &item : m_instruments)
            if (item.market == market && item.id == preferredId)
                return {{QStringLiteral("instrumentId"), item.id}, {QStringLiteral("code"), item.code}, {QStringLiteral("name"), item.name},
                        {QStringLiteral("category"), item.category}, {QStringLiteral("status"), item.status},
                        {QStringLiteral("price"), item.price}, {QStringLiteral("change"), item.change},
                        {QStringLiteral("amount"), item.amount}};
    }
    for (const MarketInstrument &item : m_instruments) {
        if (item.market != market) continue;
        return {{QStringLiteral("instrumentId"), item.id}, {QStringLiteral("code"), item.code}, {QStringLiteral("name"), item.name},
                {QStringLiteral("category"), item.category}, {QStringLiteral("status"), item.status},
                {QStringLiteral("price"), item.price}, {QStringLiteral("change"), item.change},
                {QStringLiteral("amount"), item.amount}};
    }
    return {};
}
