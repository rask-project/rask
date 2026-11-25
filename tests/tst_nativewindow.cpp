#include "tst_nativewindow.h"

#include <QSignalSpy>
#include <QTest>
#include <QWindow>
#include <Rask/Window/NativeWindow.h>

void TestNativeWindow::defaults()
{
    const rask::NativeWindow nativeWindow;
    QCOMPARE(nativeWindow.window(), nullptr);
    QVERIFY(nativeWindow.blur());
    QVERIFY(nativeWindow.unifiedToolbar());
    QVERIFY(nativeWindow.movable());
    QCOMPARE(nativeWindow.leadingInset(), 0.0);
}

void TestNativeWindow::notifiesOnlyOnChange()
{
    rask::NativeWindow nativeWindow;
    const QSignalSpy blurSpy{&nativeWindow, &rask::NativeWindow::blurChanged};
    const QSignalSpy alphaSpy{&nativeWindow, &rask::NativeWindow::alphaChanged};
    nativeWindow.setBlur(false);
    nativeWindow.setBlur(false);
    nativeWindow.setAlpha(0.5);
    nativeWindow.setAlpha(0.5);
    QCOMPARE(blurSpy.count(), 1);
    QCOMPARE(alphaSpy.count(), 1);
    QVERIFY(!nativeWindow.blur());
}

void TestNativeWindow::toleratesAWindowWithoutNativeHandle()
{
    QWindow window;
    rask::NativeWindow nativeWindow;
    nativeWindow.setWindow(&window);
    nativeWindow.titleBarDoubleClicked();
    window.show();
    QCoreApplication::processEvents();
    QCOMPARE(nativeWindow.leadingInset(), 0.0);
}

QTEST_MAIN(TestNativeWindow)
