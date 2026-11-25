#include "Updater.h"

#include "UpdaterNative_p.h"

#include <QJSEngine>
#include <QSettings>

namespace rask
{

namespace
{
constexpr auto betaKey{"Updates/betaUpdates"};
} // namespace

Updater &Updater::shared()
{
    static Updater instance;
    return instance;
}

Updater *Updater::create(QQmlEngine * /*qmlEngine*/, QJSEngine * /*jsEngine*/)
{
    Updater &updater{shared()};
    // A function-local static: the engine must not delete it.
    QJSEngine::setObjectOwnership(&updater, QJSEngine::CppOwnership);
    return &updater;
}

void Updater::start()
{
    if (updaternative::started()) {
        return;
    }
    updaternative::start(&Updater::betaUpdates, [] { emit shared().lastCheckChanged(); });
    emit automaticChecksChanged();
    emit automaticDownloadsChanged();
    emit lastCheckChanged();
}

void Updater::checkForUpdates()
{
    if (updaternative::started()) {
        updaternative::checkForUpdates();
    }
}

bool Updater::available()
{
    return updaternative::configured();
}

bool Updater::automaticChecks()
{
    return updaternative::automaticChecks();
}

void Updater::setAutomaticChecks(bool enabled)
{
    if (!updaternative::started() || enabled == automaticChecks()) {
        return;
    }
    updaternative::setAutomaticChecks(enabled);
    emit automaticChecksChanged();
}

bool Updater::automaticDownloads()
{
    return updaternative::automaticDownloads();
}

void Updater::setAutomaticDownloads(bool enabled)
{
    if (!updaternative::started() || enabled == automaticDownloads()) {
        return;
    }
    updaternative::setAutomaticDownloads(enabled);
    emit automaticDownloadsChanged();
}

bool Updater::betaUpdates()
{
    return QSettings().value(betaKey, false).toBool();
}

void Updater::setBetaUpdates(bool enabled)
{
    if (enabled == betaUpdates()) {
        return;
    }
    QSettings().setValue(betaKey, enabled);
    if (updaternative::started()) {
        updaternative::resetUpdateCycle();
    }
    emit betaUpdatesChanged();
}

QDateTime Updater::lastCheck()
{
    return updaternative::started() ? updaternative::lastCheck() : QDateTime{};
}

} // namespace rask
