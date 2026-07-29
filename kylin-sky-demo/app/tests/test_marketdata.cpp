#include "marketdataservice.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QFile>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication application(argc, argv);
    MarketDataService service;
    if (!service.ready() || !service.error().isEmpty() || service.model()->rowCount() != 10) {
        qCritical().noquote() << "market model invalid:" << service.error();
        return 1;
    }
    const QModelIndex first = service.model()->index(0, 0);
    if (service.model()->data(first, MarketTableModel::IdRole).toString() != QStringLiteral("hs300")
        || service.model()->data(first, MarketTableModel::PriceRole).toDouble() <= 0.0) {
        qCritical() << "market model first row invalid";
        return 1;
    }
    service.reload();
    if (!service.ready() || service.model()->rowCount() != 10) {
        qCritical() << "market model did not recover after reload";
        return 1;
    }
    QFile file(QStringLiteral(":/config/market-fixtures.json"));
    if (!file.open(QIODevice::ReadOnly)) return 1;
    const QJsonObject series = QJsonDocument::fromJson(file.readAll()).object().value(QStringLiteral("series")).toObject();
    for (const QString &id : {QStringLiteral("hs300"), QStringLiteral("bank-index"), QStringLiteral("au9999")}) {
        const QJsonArray rows = series.value(id).toArray();
        if (rows.size() < 8) return 1;
        for (const QJsonValue &value : rows) {
            const QJsonArray row = value.toArray();
            if (row.size() != 6 || row.at(0).toDouble() <= 0.0
                || row.at(1).toDouble() < qMax(row.at(0).toDouble(), row.at(3).toDouble())
                || row.at(2).toDouble() > qMin(row.at(0).toDouble(), row.at(3).toDouble())
                || row.at(4).toDouble() < 0.0) return 1;
        }
    }
    return 0;
}
