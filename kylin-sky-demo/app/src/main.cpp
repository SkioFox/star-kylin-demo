#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QUrl>
#include <qqml.h>

#include "appcontroller.h"
#include "manifestservice.h"
#include "marketdataservice.h"
#include "klinechartitem.h"
#include "webprofilemanager.h"

#if QT_VERSION_MAJOR >= 6
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#else
#include <QtWebEngine/QtWebEngine>
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
#elif QT_VERSION_MAJOR >= 6
    QtWebEngineQuick::initialize();
#else
    QtWebEngine::initialize();
#endif

    QGuiApplication application(argc, argv);
#if QT_VERSION < QT_VERSION_CHECK(5, 14, 0)
    QtWebEngine::initialize();
#endif
    QCoreApplication::setApplicationName(QStringLiteral("kylin-sky-demo"));
    QCoreApplication::setApplicationVersion(QStringLiteral("0.1.0"));
    QCoreApplication::setOrganizationName(QStringLiteral("Kylin Sky Demo"));
    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")), "KylinSky", 1, 0,
                             "Theme");
    qmlRegisterType<KlineChartItem>("KylinSky", 1, 0, "KlineChartItem");

    ManifestData manifest;
    QString configurationError;
    ManifestService::load(QStringLiteral(":/config/manifest.json"), &manifest, &configurationError);

    QQmlApplicationEngine engine;
    WebProfileManager webProfiles(manifest);
    AppController controller(std::move(manifest), std::move(configurationError));
    MarketDataService marketData;
    engine.rootContext()->setContextProperty(QStringLiteral("appController"), &controller);
    engine.rootContext()->setContextProperty(QStringLiteral("marketData"), &marketData);
    engine.rootContext()->setContextProperty(QStringLiteral("webProfiles"), &webProfiles);
    QObject::connect(&controller, &AppController::authenticatedChanged, &webProfiles, [&controller, &webProfiles] { if (!controller.authenticated()) webProfiles.clearSessions(); });
    const QUrl mainUrl(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &application,
                     [mainUrl](QObject *object, const QUrl &objectUrl) {
                         if (!object && objectUrl == mainUrl) {
                             QCoreApplication::exit(EXIT_FAILURE);
                         }
                     },
                     Qt::QueuedConnection);
    engine.load(mainUrl);

    return application.exec();
}
