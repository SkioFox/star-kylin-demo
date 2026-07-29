#pragma once

#include <QQuickItem>

class QKeyEvent;
class QWheelEvent;

class KlineChartItem : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(int visibleCount READ visibleCount NOTIFY viewChanged)
    Q_PROPERTY(int visibleStart READ visibleStart NOTIFY viewChanged)
    Q_PROPERTY(QString period READ period WRITE setPeriod NOTIFY periodChanged)
    Q_PROPERTY(QString instrumentId READ instrumentId WRITE setInstrumentId NOTIFY viewChanged)
public:
    explicit KlineChartItem(QQuickItem *parent = nullptr);
    int visibleCount() const;
    int visibleStart() const;
    QString period() const;
    QString instrumentId() const;
    void setPeriod(const QString &period);
    void setInstrumentId(const QString &instrumentId);
    Q_INVOKABLE void zoomIn();
    Q_INVOKABLE void zoomOut();
    Q_INVOKABLE void resetView();
signals:
    void viewChanged();
    void periodChanged();
protected:
    QSGNode *updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *) override;
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void wheelEvent(QWheelEvent *event) override;
    void keyPressEvent(QKeyEvent *event) override;
private:
    int m_visibleCount = 46;
    int m_offset = 0;
    QString m_period = QStringLiteral("日 K");
    QString m_instrumentId;
    QPointF m_dragStart;
    int m_dragOffset = 0;
};
