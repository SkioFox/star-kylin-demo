#include <QGuiApplication>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QDebug>
#include <qqml.h>

#include "klinechartitem.h"

int main(int argc, char *argv[])
{
    QGuiApplication application(argc, argv);
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")), "KylinSky", 1, 0,
                             "Theme");
    qmlRegisterType<KlineChartItem>("KylinSky", 1, 0, "KlineChartItem");

    QQmlEngine engine;
    QQmlComponent component(&engine, QUrl(QStringLiteral("qrc:/qml/KlinePanel.qml")));
    if (component.status() == QQmlComponent::Ready) return 0;

    qCritical().noquote() << component.errorString();
    return 1;
}
