#pragma once

#include <QObject>

// Runs offscreen: properties and notifications. The panels themselves are
// modal and checked by hand with the dialogs example.
class TestDialogs : public QObject
{
    Q_OBJECT
private slots:
    void aboutDialogNotifiesOnlyOnChange();
    void alertDefaults();
    void alertNotifiesOnlyOnChange();
};
