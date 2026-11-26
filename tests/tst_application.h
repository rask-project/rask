#pragma once

#include <QObject>

// Runs offscreen: the system's quit and file-open requests are simulated
// with the events Qt turns them into.
class TestApplication : public QObject
{
    Q_OBJECT
private slots:
    void init();
    void quitGuardAsksOnASystemQuit();
    void quitGuardLetsAutomaticQuitsThrough();
    void fileOpenHandlerHoldsFilesUntilConnected();
    void recentDocumentsKeepsTheLatestFirst();
    void defaultApplicationNeedsADocumentType();
    void commandLineToolNeedsABundledTool();
};
