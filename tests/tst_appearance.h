#pragma once

#include <QObject>
#include <QTemporaryDir>

class TestAppearance : public QObject
{
    Q_OBJECT
private slots:
    void initTestCase();
    void init();
    void followsTheSystemByDefault();
    void savesAndRestoresTheChoice();
    void notifiesOnlyOnChange();

private:
    QTemporaryDir m_settingsDir;
};
