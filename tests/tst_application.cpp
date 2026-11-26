#include "tst_application.h"

#include <QCoreApplication>
#include <QFileOpenEvent>
#include <QSettings>
#include <QSignalSpy>
#include <QTest>
#include <Rask/Application/CommandLineTool.h>
#include <Rask/Application/DefaultApplication.h>
#include <Rask/Application/FileOpenHandler.h>
#include <Rask/Application/QuitGuard.h>
#include <Rask/Application/RecentDocuments.h>
#include <qpa/qwindowsysteminterface.h>

void TestApplication::init()
{
    QSettings{}.remove(QStringLiteral("recentDocuments"));
}

void TestApplication::quitGuardAsksOnASystemQuit()
{
    const rask::QuitGuard guard;
    const QSignalSpy requests{&guard, &rask::QuitGuard::quitRequested};
    // What the cocoa plugin does in applicationShouldTerminate.
    QVERIFY(!QWindowSystemInterface::handleApplicationTermination<QWindowSystemInterface::SynchronousDelivery>());
    QCOMPARE(requests.count(), 1);
    QVERIFY(!guard.quitting());
}

void TestApplication::quitGuardLetsAutomaticQuitsThrough()
{
    const rask::QuitGuard guard;
    const QSignalSpy requests{&guard, &rask::QuitGuard::quitRequested};
    QEvent quit{QEvent::Quit};
    QCoreApplication::sendEvent(QCoreApplication::instance(), &quit);
    QCOMPARE(requests.count(), 0);
}

void TestApplication::fileOpenHandlerHoldsFilesUntilConnected()
{
    const rask::FileOpenHandler handler;
    const QUrl first{QUrl::fromLocalFile(QStringLiteral("/tmp/a.txt"))};
    const QUrl second{QUrl::fromLocalFile(QStringLiteral("/tmp/b.txt"))};
    QFileOpenEvent firstEvent{first};
    QFileOpenEvent secondEvent{second};
    QCoreApplication::sendEvent(QCoreApplication::instance(), &firstEvent);
    QCoreApplication::sendEvent(QCoreApplication::instance(), &secondEvent);
    QCoreApplication::processEvents();

    // Connecting delivers what came before.
    QList<QUrl> received;
    connect(&handler, &rask::FileOpenHandler::filesOpened, this, [&received](const QList<QUrl> &files) {
        received = files;
    });
    QVERIFY(QTest::qWaitFor([&received] { return !received.isEmpty(); }));
    QCOMPARE(received, (QList<QUrl>{first, second}));
}

void TestApplication::recentDocumentsKeepsTheLatestFirst()
{
    rask::RecentDocuments recent;
    const QSignalSpy changes{&recent, &rask::RecentDocuments::filesChanged};
    for (qint32 index{0}; index < 12; ++index) {
        recent.add(QUrl::fromLocalFile(QStringLiteral("/tmp/%1.txt").arg(index)));
    }
    recent.add(QUrl::fromLocalFile(QStringLiteral("/tmp/5.txt")));
    recent.add(QUrl::fromLocalFile(QStringLiteral("/tmp/5.txt")));
    recent.add(QUrl{QStringLiteral("https://example.com/remote.txt")});
    const QList<QUrl> files{rask::RecentDocuments::files()};
    QCOMPARE(files.size(), rask::RecentDocuments::maximumCount);
    QCOMPARE(files.first(), QUrl::fromLocalFile(QStringLiteral("/tmp/5.txt")));
    QCOMPARE(files.at(1), QUrl::fromLocalFile(QStringLiteral("/tmp/11.txt")));
    QCOMPARE(changes.count(), 13);
    recent.clear();
    QVERIFY(rask::RecentDocuments::files().isEmpty());
}

// The test is no bundle: it declares no document types and bundles no tools.
void TestApplication::defaultApplicationNeedsADocumentType()
{
    QVERIFY(!rask::DefaultApplication::isDefault(QStringLiteral("Text")));
    QVERIFY(!rask::DefaultApplication::makeDefault(QStringLiteral("Text")));
}

void TestApplication::commandLineToolNeedsABundledTool()
{
    QVERIFY(!rask::CommandLineTool::isInstalled(QStringLiteral("rask-test-tool")));
    QVERIFY(!rask::CommandLineTool::install(QStringLiteral("rask-test-tool")));
}

QTEST_MAIN(TestApplication)
