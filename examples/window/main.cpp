#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QCoreApplication::setOrganizationDomain(QStringLiteral("com.github.rask-project"));
    QCoreApplication::setOrganizationName(QStringLiteral("rask-project"));
    QCoreApplication::setApplicationName(QStringLiteral("Rask Window Example"));

    const QGuiApplication app{argc, argv};

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection
    );
    engine.loadFromModule("RaskWindowExample", "Main");

    return QGuiApplication::exec();
}
