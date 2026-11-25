#pragma once

#include <QObject>
#include <QTemporaryDir>

// The test binary has no Info.plist feed or key: Sparkle never starts, and
// the updater must stay a harmless no-op.
class TestUpdater : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void unavailableWithoutFeed();
    void startIsHarmlessWithoutFeed();
    void savesBetaChoice();

private:
    QTemporaryDir m_settingsDir;
};
