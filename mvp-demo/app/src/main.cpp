#include "appcontroller.h"
#include "manifestservice.h"
#include "webprofilemanager.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#if QT_VERSION_MAJOR >= 6
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#else
#include <QtWebEngine/QtWebEngine>
#endif

int main(int argc, char *argv[])
{
#if QT_VERSION_MAJOR >= 6
    QtWebEngineQuick::initialize();
#else
    QtWebEngine::initialize();
#endif

    QGuiApplication application(argc, argv);
    QCoreApplication::setApplicationName(QStringLiteral("star-kylin-demo"));
    QCoreApplication::setApplicationVersion(QStringLiteral("0.1.0"));
    QCoreApplication::setOrganizationName(QStringLiteral("Star Kylin Demo"));

    ManifestData manifest;
    QString configurationError;
    ManifestService::load(QStringLiteral(":/config/manifest.json"), &manifest,
                          &configurationError);
    WebProfileManager webProfiles(manifest);
    AppController controller(std::move(manifest), configurationError);
    QObject::connect(&controller, &AppController::authenticatedChanged, &webProfiles,
                     [&controller, &webProfiles]() {
                         if (!controller.authenticated()) {
                             webProfiles.clearBusinessSession();
                         }
                     });

    qmlRegisterSingletonType(QUrl(QStringLiteral("qrc:/qml/Theme.qml")), "StarKylin", 1, 0,
                             "Theme");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("appController"), &controller);
    engine.rootContext()->setContextProperty(QStringLiteral("webProfiles"), &webProfiles);
    const QUrl mainUrl(QStringLiteral("qrc:/qml/Main.qml"));
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated, &application,
        [mainUrl](QObject *object, const QUrl &objectUrl) {
            if (!object && objectUrl == mainUrl) {
                QCoreApplication::exit(EXIT_FAILURE);
            }
        },
        Qt::QueuedConnection);
    engine.load(mainUrl);

    return application.exec();
}
