#include "klinechartitem.h"

#include <QGuiApplication>
#include <QtTest>

class KlineChartTest final : public QObject {
    Q_OBJECT
private slots:
    void aggregatesPeriodsAndKeepsTheViewportBounded();
};

void KlineChartTest::aggregatesPeriodsAndKeepsTheViewportBounded()
{
    KlineChartItem chart;
    chart.setInstrumentId(QStringLiteral("hs300"));
    chart.setPeriod(QStringLiteral("日 K"));
    const int dailyCount = chart.visibleCount();
    QVERIFY(dailyCount > 0);

    chart.setPeriod(QStringLiteral("周 K"));
    const int weeklyCount = chart.visibleCount();
    QVERIFY(weeklyCount > 0);
    QVERIFY(weeklyCount < dailyCount);

    chart.setPeriod(QStringLiteral("月 K"));
    const int monthlyCount = chart.visibleCount();
    QVERIFY(monthlyCount > 0);
    QVERIFY(monthlyCount < weeklyCount);
    QCOMPARE(chart.visibleStart(), 0);

    chart.setPeriod(QStringLiteral("日 K"));
    const int beforeZoom = chart.visibleCount();
    chart.zoomIn();
    QVERIFY(chart.visibleCount() <= beforeZoom);
    chart.resetView();
    QVERIFY(chart.visibleStart() >= 0);
}

int main(int argc, char *argv[])
{
    QGuiApplication application(argc, argv);
    KlineChartTest test;
    return QTest::qExec(&test, argc, argv);
}

#include "test_klinechart.moc"
