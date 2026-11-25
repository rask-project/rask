#include "tst_glasseffect.h"

#include <QQuickWindow>
#include <QSignalSpy>
#include <QTest>
#include <Rask/Window/GlassEffect.h>

void TestGlassEffect::notifiesOnlyOnChange()
{
    rask::GlassEffect glass;
    const QSignalSpy radiusSpy{&glass, &rask::GlassEffect::cornerRadiusChanged};
    const QSignalSpy tintSpy{&glass, &rask::GlassEffect::tintChanged};
    const QSignalSpy clearSpy{&glass, &rask::GlassEffect::clearChanged};
    glass.setCornerRadius(12.0);
    glass.setCornerRadius(12.0);
    glass.setTint(QColor{0x33, 0x80, 0xff, 0x59});
    glass.setTint(QColor{0x33, 0x80, 0xff, 0x59});
    glass.setClear(true);
    glass.setClear(true);
    QCOMPARE(radiusSpy.count(), 1);
    QCOMPARE(tintSpy.count(), 1);
    QCOMPARE(clearSpy.count(), 1);
    QCOMPARE(glass.tint(), QColor(0x33, 0x80, 0xff, 0x59));
}

void TestGlassEffect::survivesWindowChanges()
{
    QQuickWindow first;
    QQuickWindow second;
    rask::GlassEffect glass;
    glass.setSize({100.0, 40.0});
    glass.setParentItem(first.contentItem());
    first.show();
    QVERIFY(QTest::qWaitForWindowExposed(&first));
    glass.setOpacity(0.5);
    glass.setParentItem(second.contentItem());
    second.show();
    QVERIFY(QTest::qWaitForWindowExposed(&second));
    glass.setParentItem(nullptr);
    QCoreApplication::processEvents();
}

QTEST_MAIN(TestGlassEffect)
