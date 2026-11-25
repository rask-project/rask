#include "tst_appearance.h"

#include <QSettings>
#include <QSignalSpy>
#include <QTest>
#include <Rask/Platform/Appearance.h>

void TestAppearance::initTestCase()
{
    QVERIFY(m_settingsDir.isValid());
    QSettings::setDefaultFormat(QSettings::IniFormat);
    QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, m_settingsDir.path());
}

void TestAppearance::init()
{
    QSettings().clear();
}

void TestAppearance::followsTheSystemByDefault()
{
    const rask::Appearance appearance;
    QCOMPARE(appearance.colorScheme(), Qt::ColorScheme::Unknown);
}

void TestAppearance::savesAndRestoresTheChoice()
{
    {
        rask::Appearance appearance;
        appearance.setColorScheme(Qt::ColorScheme::Dark);
        QVERIFY(appearance.dark());
    }
    const rask::Appearance restored;
    QCOMPARE(restored.colorScheme(), Qt::ColorScheme::Dark);
    QVERIFY(restored.dark());
}

void TestAppearance::notifiesOnlyOnChange()
{
    rask::Appearance appearance;
    const QSignalSpy spy{&appearance, &rask::Appearance::colorSchemeChanged};
    appearance.setColorScheme(Qt::ColorScheme::Light);
    appearance.setColorScheme(Qt::ColorScheme::Light);
    QCOMPARE(spy.count(), 1);
    QVERIFY(!appearance.dark());
}

QTEST_MAIN(TestAppearance)
