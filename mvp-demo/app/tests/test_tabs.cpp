#include "tablistmodel.h"

#include <QtTest>

class TabListModelTest final : public QObject {
    Q_OBJECT

private slots:
    void keepsWorkbenchAndUsesSingleInstance()
    {
        TabListModel model;
        QCOMPARE(model.rowCount(), 1);
        QCOMPARE(model.activeId(), QStringLiteral("workbench"));

        ModuleDefinition web;
        web.id = QStringLiteral("appWeb");
        web.name = QStringLiteral("Web 业务");
        web.icon = QStringLiteral("globe-2");
        model.openModule(web);
        model.openModule(web);

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.activeId(), QStringLiteral("appWeb"));
        QVERIFY(!model.close(QStringLiteral("workbench")));
    }

    void closesToLeftNeighbor()
    {
        TabListModel model;
        ModuleDefinition web;
        web.id = QStringLiteral("appWeb");
        web.name = QStringLiteral("Web 业务");
        web.icon = QStringLiteral("globe-2");
        ModuleDefinition kline;
        kline.id = QStringLiteral("appKline");
        kline.name = QStringLiteral("行情中心");
        kline.icon = QStringLiteral("chart-candlestick");

        model.openModule(web);
        model.openModule(kline);
        QVERIFY(model.close(QStringLiteral("appKline")));
        QCOMPARE(model.activeId(), QStringLiteral("appWeb"));
        QVERIFY(model.close(QStringLiteral("appWeb")));
        QCOMPARE(model.activeId(), QStringLiteral("workbench"));
    }
};

QTEST_APPLESS_MAIN(TabListModelTest)
#include "test_tabs.moc"
