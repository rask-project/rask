#pragma once

#include <QObject>

// Runs offscreen: Rask.Controls loads from the library's resources and its
// types build without QML errors.
class TestControls : public QObject
{
    Q_OBJECT
private slots:
    void createsEveryType_data();
    void createsEveryType();
    void sidebarLayoutFollowsSelection();
};
