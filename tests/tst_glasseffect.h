#pragma once

#include <QObject>

// Runs offscreen: properties, and that the item survives being shown in,
// moved between and removed from windows without a native glass view.
class TestGlassEffect : public QObject
{
    Q_OBJECT
private slots:
    void notifiesOnlyOnChange();
    void survivesWindowChanges();
};
