#pragma once

#include <QObject>

// Runs offscreen: the properties and their notifications, and that nothing
// native is touched without a cocoa window.
class TestNativeWindow : public QObject
{
    Q_OBJECT
private slots:
    void defaults();
    void notifiesOnlyOnChange();
    void documentPropertiesNotifyOnlyOnChange();
    void toleratesAWindowWithoutNativeHandle();
};
