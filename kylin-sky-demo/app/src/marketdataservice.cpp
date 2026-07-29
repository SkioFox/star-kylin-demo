#include "marketdataservice.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QSet>
#include <QTimer>

MarketDataService::MarketDataService(QObject *parent) : QObject(parent), m_model(this)
{
    m_timer = new QTimer(this);
    m_timer->setInterval(1000);
    connect(m_timer, &QTimer::timeout, this, [this] {
        const int count = m_model.rowCount();
        if (!count) return;
        const int row = m_tick++ % count;
        const QModelIndex index = m_model.index(row, 0);
        const double price = m_model.data(index, MarketTableModel::PriceRole).toDouble();
        const double change = m_model.data(index, MarketTableModel::ChangeRole).toDouble();
        const double drift = row % 2 == 0 ? 0.01 : -0.01;
        m_model.updateInstrument(row, price * (1.0 + drift / 100.0), change + drift);
    });
    reload();
}

MarketTableModel *MarketDataService::model() { return &m_model; }
QString MarketDataService::error() const { return m_error; }
bool MarketDataService::ready() const { return m_error.isEmpty() && m_model.rowCount() > 0; }

void MarketDataService::reload()
{
    m_timer->stop();
    m_error.clear();
    m_model.setInstruments({});
    if (load()) startUpdates();
    emit stateChanged();
}

void MarketDataService::startUpdates()
{
    if (ready()) m_timer->start();
}

bool MarketDataService::load()
{
    QFile file(QStringLiteral(":/config/market-fixtures.json"));
    if (!file.open(QIODevice::ReadOnly)) { m_error = QStringLiteral("无法读取本地行情数据"); return false; }
    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()
        || document.object().value(QStringLiteral("version")).toInt() != 1) {
        m_error = QStringLiteral("本地行情数据格式无效"); return false;
    }
    QList<MarketInstrument> instruments;
    QSet<QString> ids;
    for (const QJsonValue &value : document.object().value(QStringLiteral("instruments")).toArray()) {
        const QJsonObject object = value.toObject();
        MarketInstrument item;
        item.id = object.value(QStringLiteral("id")).toString();
        item.code = object.value(QStringLiteral("code")).toString();
        item.name = object.value(QStringLiteral("name")).toString();
        item.category = object.value(QStringLiteral("category")).toString();
        item.market = object.value(QStringLiteral("market")).toString();
        item.price = object.value(QStringLiteral("price")).toDouble(-1.0);
        item.change = object.value(QStringLiteral("change")).toDouble(99999.0);
        item.amount = object.value(QStringLiteral("amount")).toString();
        item.status = object.value(QStringLiteral("status")).toString();
        if (item.id.isEmpty() || ids.contains(item.id) || item.code.isEmpty() || item.name.isEmpty()
            || item.category.isEmpty() || item.market.isEmpty() || item.price <= 0.0
            || item.change == 99999.0 || item.amount.isEmpty() || item.status.isEmpty()) {
            m_error = QStringLiteral("本地行情数据未通过完整性校验"); return false;
        }
        ids.insert(item.id);
        instruments.append(item);
    }
    if (instruments.isEmpty()) { m_error = QStringLiteral("本地行情数据为空"); return false; }
    m_model.setInstruments(std::move(instruments));
    return true;
}
