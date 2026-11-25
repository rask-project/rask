#include "tst_systemcolors.h"

#include <QTest>
#include <Rask/Platform/SystemColors.h>

// Following light/dark needs a real NSApp (tests run offscreen): checked by hand.
void TestSystemColors::resolvesTheSemanticColors()
{
    const rask::SystemColors colors;
    QVERIFY(colors.label().isValid());
    QVERIFY(colors.secondaryLabel().alphaF() < colors.label().alphaF());
    QVERIFY(colors.text().isValid());
    QVERIFY(colors.selectedTextBackground().isValid());
    QVERIFY(colors.textInsertionPoint().isValid());
    QVERIFY(colors.controlAccent().isValid());
    QVERIFY(colors.findHighlight().isValid());
}

QTEST_MAIN(TestSystemColors)
