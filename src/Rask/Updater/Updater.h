#pragma once

#include <Rask/Updater/raskupdater_export.h>

#include <QDateTime>
#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

class QJSEngine;
class QQmlEngine;

namespace rask
{

// Updates through Sparkle (macOS): "Check for Updates…" in the app menu, the
// release notes, download, EdDSA check, install and relaunch. The feed and
// key come from the app's Info.plist (SUFeedURL, SUPublicEDKey — see
// rask_sparkle_plist_keys()); without them, and outside macOS, `available`
// is false and everything is a no-op.
//
// Pre-releases are posted to the appcast's "beta" channel; only users who
// turn on `betaUpdates` see them.
class RASK_UPDATER_EXPORT Updater final : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool available READ available CONSTANT)
    Q_PROPERTY(bool automaticChecks READ automaticChecks WRITE setAutomaticChecks NOTIFY automaticChecksChanged)
    Q_PROPERTY(bool automaticDownloads READ automaticDownloads WRITE setAutomaticDownloads NOTIFY
                   automaticDownloadsChanged)
    Q_PROPERTY(bool betaUpdates READ betaUpdates WRITE setBetaUpdates NOTIFY betaUpdatesChanged)
    // When Sparkle last looked for an update; invalid if it never did.
    Q_PROPERTY(QDateTime lastCheck READ lastCheck NOTIFY lastCheckChanged)
public:
    static Updater &shared();
    static Updater *create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);
    ~Updater() override = default;
    Q_DISABLE_COPY_MOVE(Updater)

    // Starts Sparkle's scheduled checks and adds the menu item. Call it once
    // the app's menu bar exists (C++ or QML); later calls do nothing.
    Q_INVOKABLE void start();
    // Checks now and shows the result, even when no update is found.
    Q_INVOKABLE void checkForUpdates();

    [[nodiscard]] static bool available();
    [[nodiscard]] static bool automaticChecks();
    void setAutomaticChecks(bool enabled);
    [[nodiscard]] static bool automaticDownloads();
    void setAutomaticDownloads(bool enabled);
    [[nodiscard]] static bool betaUpdates();
    void setBetaUpdates(bool enabled);
    [[nodiscard]] static QDateTime lastCheck();

signals:
    void automaticChecksChanged();
    void automaticDownloadsChanged();
    void betaUpdatesChanged();
    void lastCheckChanged();

private:
    Updater() = default;
};

} // namespace rask
