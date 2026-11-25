#include "tst_dialogs.h"

#include <QSignalSpy>
#include <QTest>
#include <Rask/Dialogs/AboutDialog.h>
#include <Rask/Dialogs/Alert.h>

void TestDialogs::aboutDialogNotifiesOnlyOnChange()
{
    rask::AboutDialog dialog;
    const QSignalSpy spy{&dialog, &rask::AboutDialog::versionChanged};
    dialog.setVersion(QStringLiteral("Version 1.0"));
    dialog.setVersion(QStringLiteral("Version 1.0"));
    QCOMPARE(spy.count(), 1);
    QCOMPARE(dialog.version(), QStringLiteral("Version 1.0"));
}

void TestDialogs::alertDefaults()
{
    const rask::Alert alert;
    QCOMPARE(alert.style(), rask::Alert::Style::Informational);
    QCOMPARE(alert.buttons(), QStringList{QStringLiteral("OK")});
    QCOMPARE(alert.result(), -1);
    QCOMPARE(alert.window(), nullptr);
}

void TestDialogs::alertNotifiesOnlyOnChange()
{
    rask::Alert alert;
    const QSignalSpy styleSpy{&alert, &rask::Alert::styleChanged};
    const QSignalSpy buttonsSpy{&alert, &rask::Alert::buttonsChanged};
    alert.setStyle(rask::Alert::Style::Warning);
    alert.setStyle(rask::Alert::Style::Warning);
    const QStringList buttons{QStringLiteral("Save"), QStringLiteral("Cancel")};
    alert.setButtons(buttons);
    alert.setButtons(buttons);
    QCOMPARE(styleSpy.count(), 1);
    QCOMPARE(buttonsSpy.count(), 1);
}

QTEST_MAIN(TestDialogs)
