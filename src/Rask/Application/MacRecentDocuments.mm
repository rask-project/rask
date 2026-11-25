#import <AppKit/AppKit.h>

#include "MacRecentDocuments_p.h"

#include <QGuiApplication>

namespace rask::macrecent
{

namespace
{

// Tests run offscreen, outside an app bundle: leave the system's list alone.
bool available()
{
    return QGuiApplication::platformName() == QLatin1String("cocoa");
}

} // namespace

void note(const QString &path)
{
    if (!available()) {
        return;
    }
    [[NSDocumentController sharedDocumentController]
        noteNewRecentDocumentURL:[NSURL fileURLWithPath:path.toNSString()]];
}

void clear()
{
    if (!available()) {
        return;
    }
    [[NSDocumentController sharedDocumentController] clearRecentDocuments:nil];
}

} // namespace rask::macrecent
