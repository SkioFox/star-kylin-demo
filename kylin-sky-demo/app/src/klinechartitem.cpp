#include "klinechartitem.h"

#include <QColor>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QKeyEvent>
#include <QMouseEvent>
#include <QWheelEvent>
#include <QSGNode>
#include <QSGSimpleRectNode>
#include <QtMath>

namespace {
struct Candle { qreal open; qreal close; qreal high; qreal low; qreal volume; qreal macd; };
QList<Candle> fixtureSeries(const QString &instrument)
{
    static QHash<QString, QList<Candle>> cache;
    static bool loaded = false;
    if (!loaded) {
        loaded = true;
        QFile file(QStringLiteral(":/config/market-fixtures.json"));
        if (file.open(QIODevice::ReadOnly)) {
            const QJsonObject series = QJsonDocument::fromJson(file.readAll()).object().value(QStringLiteral("series")).toObject();
            for (auto it = series.constBegin(); it != series.constEnd(); ++it) {
                QList<Candle> values;
                for (const QJsonValue &value : it.value().toArray()) {
                    const QJsonArray row = value.toArray();
                    if (row.size() != 6) { values.clear(); break; }
                    const qreal open = row.at(0).toDouble(-1.0), high = row.at(1).toDouble(-1.0);
                    const qreal low = row.at(2).toDouble(-1.0), close = row.at(3).toDouble(-1.0), volume = row.at(4).toDouble(-1.0), macd = row.at(5).toDouble();
                    if (open <= 0.0 || high < qMax(open, close) || low > qMin(open, close) || volume < 0.0) { values.clear(); break; }
                    values.append({open, close, high, low, volume, macd});
                }
                if (!values.isEmpty()) cache.insert(it.key(), values);
            }
        }
    }
    return cache.value(instrument);
}
QList<Candle> aggregate(const QList<Candle> &source, int groupSize)
{
    if (groupSize <= 1 || source.isEmpty()) return source;
    QList<Candle> result;
    for (int start = 0; start < source.size(); start += groupSize) {
        const int end = qMin(start + groupSize, source.size());
        Candle combined = source.at(start);
        combined.volume = 0.0;
        combined.high = source.at(start).high;
        combined.low = source.at(start).low;
        for (int index = start; index < end; ++index) {
            const Candle &item = source.at(index);
            combined.high = qMax(combined.high, item.high);
            combined.low = qMin(combined.low, item.low);
            combined.close = item.close;
            combined.volume += item.volume;
            combined.macd = item.macd;
        }
        result.append(combined);
    }
    return result;
}
QList<Candle> seriesFor(const QString &instrument, const QString &period)
{
    const QList<Candle> fixture = fixtureSeries(instrument);
    if (!fixture.isEmpty()) {
        if (period == QStringLiteral("周 K")) return aggregate(fixture, 5);
        if (period == QStringLiteral("月 K")) return aggregate(fixture, 15);
        return fixture;
    }
    QList<Candle> series;
    const qreal base = instrument == QStringLiteral("au9999") ? 772.0
                      : instrument == QStringLiteral("bank-index") ? 4310.0 : 3820.0;
    const qreal scale = base > 1000.0 ? base * 0.002 : 1.8;
    qreal previous = base;
    for (int i = 0; i < 90; ++i) {
        const qreal drift = qSin(i * 0.41) * scale + qCos(i * 0.13) * scale * 0.58;
        const qreal open = previous;
        const qreal close = open + drift;
        series.append({open, close, qMax(open, close) + scale * (0.45 + (i % 3) * .13),
                       qMin(open, close) - scale * (0.38 + (i % 4) * .08),
                       32.0 + (i * 17 % 80), qSin(i * .27) * 1.2 + qCos(i * .09) * .45});
        previous = close;
    }
    return series;
}
void rect(QSGNode *root, qreal x, qreal y, qreal width, qreal height, const QColor &color)
{
    root->appendChildNode(new QSGSimpleRectNode(QRectF(x, y, qMax<qreal>(1.0, width), qMax<qreal>(1.0, height)), color));
}
} // namespace

KlineChartItem::KlineChartItem(QQuickItem *parent) : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
    setAcceptedMouseButtons(Qt::LeftButton);
    setActiveFocusOnTab(true);
}
int KlineChartItem::visibleCount() const
{
    return qMin(m_visibleCount, seriesFor(m_instrumentId, m_period).size());
}
int KlineChartItem::visibleStart() const
{
    const QList<Candle> values = seriesFor(m_instrumentId, m_period);
    const int count = qMin(m_visibleCount, values.size());
    return qBound(0, values.size() - count - m_offset, qMax(0, values.size() - count));
}
QString KlineChartItem::period() const { return m_period; }
QString KlineChartItem::instrumentId() const { return m_instrumentId; }
void KlineChartItem::setPeriod(const QString &period) { if (m_period != period) { m_period = period; m_offset = 0; emit periodChanged(); emit viewChanged(); update(); } }
void KlineChartItem::setInstrumentId(const QString &id) { if (m_instrumentId != id) { m_instrumentId = id; m_offset = 0; emit viewChanged(); update(); } }
void KlineChartItem::zoomIn() { if (m_visibleCount > 18) { m_visibleCount -= 6; emit viewChanged(); update(); } }
void KlineChartItem::zoomOut() { if (m_visibleCount < 76) { m_visibleCount += 6; emit viewChanged(); update(); } }
void KlineChartItem::resetView() { m_visibleCount = 46; m_offset = 0; emit viewChanged(); update(); }

QSGNode *KlineChartItem::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *root = oldNode ? oldNode : new QSGNode;
    root->removeAllChildNodes();
    const qreal w = width(), h = height();
    if (w < 40 || h < 80) return root;
    const QColor grid("#E4EBF2"), up("#C13D48"), down("#26805B"), ma("#286AB2"), macd("#B98332");
    for (int row = 0; row < 6; ++row) rect(root, 0, row * h * .62 / 5.0, w, 1, grid);
    for (int col = 0; col < 7; ++col) rect(root, col * w / 6.0, 0, 1, h, grid);
    const QList<Candle> values = seriesFor(m_instrumentId, m_period);
    if (values.isEmpty()) return root;
    const int count = qMin(m_visibleCount, values.size());
    const int start = qBound(0, values.size() - count - m_offset, values.size() - count);
    qreal min = values.at(start).low, max = values.at(start).high, volumeMax = 1.0;
    for (int i = start; i < start + count; ++i) { min = qMin(min, values.at(i).low); max = qMax(max, values.at(i).high); volumeMax = qMax(volumeMax, values.at(i).volume); }
    const qreal chartH = h * .60, volumeTop = h * .66, volumeH = h * .17, macdTop = h * .87, macdH = h * .10;
    const qreal step = w / count, bodyW = qMax<qreal>(2.0, step * .58);
    auto priceY = [=](qreal value) { return (max - value) * chartH / qMax<qreal>(.001, max - min); };
    qreal previousMa = -1;
    for (int item = 0; item < count; ++item) {
        const Candle &candle = values.at(start + item);
        const qreal x = item * step + step * .5;
        const QColor color = candle.close >= candle.open ? up : down;
        const qreal openY = priceY(candle.open), closeY = priceY(candle.close);
        rect(root, x - .6, priceY(candle.high), 1.2, priceY(candle.low) - priceY(candle.high), color);
        rect(root, x - bodyW * .5, qMin(openY, closeY), bodyW, qAbs(closeY - openY), color);
        rect(root, x - bodyW * .5, volumeTop + volumeH * (1.0 - candle.volume / volumeMax), bodyW,
             volumeH * candle.volume / volumeMax, QColor(color.red(), color.green(), color.blue(), 100));
        const qreal zero = macdTop + macdH * .5;
        const qreal macdY = zero - candle.macd * macdH * .28;
        rect(root, x - bodyW * .42, qMin(zero, macdY), bodyW * .84, qAbs(macdY - zero), candle.macd >= 0 ? up : down);
        const qreal average = (candle.close + candle.open) * .5;
        const qreal maY = priceY(average);
        if (previousMa >= 0) {
            const qreal fromX = (item - 1) * step + step * .5;
            const qreal dx = x - fromX, dy = maY - previousMa;
            const int segments = qMax(1, qRound(qAbs(dx) + qAbs(dy)));
            for (int segment = 0; segment < segments; ++segment)
                rect(root, fromX + dx * segment / segments, previousMa + dy * segment / segments, 1.4, 1.4, ma);
        }
        previousMa = maY;
    }
    rect(root, 0, volumeTop - 1, w, 1, grid); rect(root, 0, macdTop - 1, w, 1, grid); rect(root, 0, macdTop + macdH * .5, w, 1, grid);
    return root;
}

void KlineChartItem::mousePressEvent(QMouseEvent *event) { m_dragStart = event->localPos(); m_dragOffset = m_offset; event->accept(); }
void KlineChartItem::mouseMoveEvent(QMouseEvent *event)
{
    if (!(event->buttons() & Qt::LeftButton)) return;
    const int maxOffset = qMax(0, seriesFor(m_instrumentId, m_period).size() - m_visibleCount);
    m_offset = qBound(0, m_dragOffset + qRound((event->localPos().x() - m_dragStart.x()) / qMax<qreal>(4.0, width() / m_visibleCount)), maxOffset);
    emit viewChanged(); update(); event->accept();
}

void KlineChartItem::wheelEvent(QWheelEvent *event)
{
    if (event->angleDelta().y() > 0) zoomIn();
    else if (event->angleDelta().y() < 0) zoomOut();
    event->accept();
}

void KlineChartItem::keyPressEvent(QKeyEvent *event)
{
    const int maxOffset = qMax(0, seriesFor(m_instrumentId, m_period).size() - m_visibleCount);
    if (event->key() == Qt::Key_Left) m_offset = qMin(maxOffset, m_offset + 1);
    else if (event->key() == Qt::Key_Right) m_offset = qMax(0, m_offset - 1);
    else if (event->key() == Qt::Key_Plus || event->key() == Qt::Key_Equal) { zoomIn(); event->accept(); return; }
    else if (event->key() == Qt::Key_Minus || event->key() == Qt::Key_Underscore) { zoomOut(); event->accept(); return; }
    else if (event->key() == Qt::Key_R) { resetView(); event->accept(); return; }
    else { QQuickItem::keyPressEvent(event); return; }
    emit viewChanged();
    update();
    event->accept();
}
