#include <QDate>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QtTest>

namespace {

struct Candle {
    QDate date;
    double open = 0;
    double high = 0;
    double low = 0;
    double close = 0;
    qint64 volume = 0;
};

enum class Period { Week, Month };

QString groupKey(const Candle &candle, Period period)
{
    if (period == Period::Week) {
        return candle.date.addDays(1 - candle.date.dayOfWeek()).toString(Qt::ISODate);
    }
    return candle.date.toString(QStringLiteral("yyyy-MM"));
}

QList<Candle> aggregate(const QList<Candle> &records, Period period)
{
    QList<Candle> result;
    QString activeKey;
    Candle current;
    for (const Candle &record : records) {
        const QString key = groupKey(record, period);
        if (key != activeKey) {
            if (!activeKey.isEmpty()) {
                result.append(current);
            }
            activeKey = key;
            current = record;
            continue;
        }
        current.date = record.date;
        current.high = qMax(current.high, record.high);
        current.low = qMin(current.low, record.low);
        current.close = record.close;
        current.volume += record.volume;
    }
    if (!activeKey.isEmpty()) {
        result.append(current);
    }
    return result;
}

QList<Candle> readDaily()
{
    QFile file(QStringLiteral(":/web-kline/mock-market.json"));
    if (!file.open(QIODevice::ReadOnly)) {
        return {};
    }
    const QJsonDocument document = QJsonDocument::fromJson(file.readAll());
    QList<Candle> result;
    for (const QJsonValue &value : document.object().value(QStringLiteral("daily")).toArray()) {
        const QJsonObject object = value.toObject();
        Candle candle;
        candle.date = QDate::fromString(object.value(QStringLiteral("date")).toString(), Qt::ISODate);
        candle.open = object.value(QStringLiteral("open")).toDouble();
        candle.high = object.value(QStringLiteral("high")).toDouble();
        candle.low = object.value(QStringLiteral("low")).toDouble();
        candle.close = object.value(QStringLiteral("close")).toDouble();
        candle.volume = object.value(QStringLiteral("volume")).toVariant().toLongLong();
        result.append(candle);
    }
    return result;
}

void verifyLastGroup(const QList<Candle> &records, const QList<Candle> &aggregated, Period period)
{
    const QString lastKey = groupKey(records.last(), period);
    QList<Candle> source;
    for (const Candle &record : records) {
        if (groupKey(record, period) == lastKey) {
            source.append(record);
        }
    }
    const Candle &actual = aggregated.last();
    QCOMPARE(actual.date, source.last().date);
    QCOMPARE(actual.open, source.first().open);
    QCOMPARE(actual.close, source.last().close);
    qint64 volume = 0;
    double high = source.first().high;
    double low = source.first().low;
    for (const Candle &record : source) {
        high = qMax(high, record.high);
        low = qMin(low, record.low);
        volume += record.volume;
    }
    QCOMPARE(actual.high, high);
    QCOMPARE(actual.low, low);
    QCOMPARE(actual.volume, volume);
}

} // namespace

class KlineDataTest final : public QObject {
    Q_OBJECT

private slots:
    void fixedDailyDataHasExpectedShape()
    {
        const QList<Candle> records = readDaily();
        QCOMPARE(records.size(), 380);
        QCOMPARE(records.last().date, QDate(2026, 7, 21));
        for (const Candle &record : records) {
            QVERIFY(record.date.isValid());
            QVERIFY(record.date.dayOfWeek() <= 5);
            QVERIFY(record.low <= qMin(record.open, record.close));
            QVERIFY(record.high >= qMax(record.open, record.close));
            QVERIFY(record.volume > 0);
        }
        QCOMPARE(records.mid(records.size() - 60).size(), 60);
    }

    void naturalWeekAndMonthAggregationPreservesOhlcv()
    {
        const QList<Candle> records = readDaily();
        const QList<Candle> weeks = aggregate(records, Period::Week);
        const QList<Candle> months = aggregate(records, Period::Month);

        QVERIFY(weeks.size() >= 52);
        QVERIFY(months.size() >= 18);
        QCOMPARE(weeks.mid(weeks.size() - 52).size(), 52);
        QCOMPARE(months.mid(months.size() - 18).size(), 18);
        verifyLastGroup(records, weeks, Period::Week);
        verifyLastGroup(records, months, Period::Month);
    }
};

QTEST_APPLESS_MAIN(KlineDataTest)
#include "test_kline_data.moc"
