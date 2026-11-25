#include "tst_updater.h"

#include <QSettings>
#include <QSignalSpy>
#include <QTest>
#include <Rask/Updater/Updater.h>

void TestUpdater::initTestCase()
{
    QVERIFY(m_settingsDir.isValid());
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, m_settingsDir.path());
}

void TestUpdater::unavailableWithoutFeed()
{
    QVERIFY(!rask::Updater::available());
    QVERIFY(!rask::Updater::automaticChecks());
    QVERIFY(!rask::Updater::lastCheck().isValid());
}

void TestUpdater::startIsHarmlessWithoutFeed()
{
    rask::Updater &updater{rask::Updater::shared()};
    updater.start();
    updater.checkForUpdates();
    const QSignalSpy spy{&updater, &rask::Updater::automaticChecksChanged};
    updater.setAutomaticChecks(true);
    QCOMPARE(spy.count(), 0);
    QVERIFY(!rask::Updater::automaticChecks());
}

void TestUpdater::savesBetaChoice()
{
    rask::Updater &updater{rask::Updater::shared()};
    const QSignalSpy spy{&updater, &rask::Updater::betaUpdatesChanged};
    updater.setBetaUpdates(true);
    updater.setBetaUpdates(true);
    QCOMPARE(spy.count(), 1);
    QVERIFY(rask::Updater::betaUpdates());
    updater.setBetaUpdates(false);
}

QTEST_MAIN(TestUpdater)
