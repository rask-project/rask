#import <AppKit/AppKit.h>

#include "NativeDialogs_p.h"

#include <QFile>
#include <QGuiApplication>

#include <algorithm>
#include <bit>

namespace
{

NSWindow *nsWindow(QWindow *window)
{
    if (window == nullptr || window->handle() == nullptr || QGuiApplication::platformName() != QLatin1String("cocoa")) {
        return nil;
    }
    NSView *const view{(__bridge NSView *) std::bit_cast<void *>(window->winId())};
    return [view window];
}

NSImage *imageFromResource(const QString &path)
{
    QFile file{path};
    if (!file.open(QIODevice::ReadOnly)) {
        return nil;
    }
    const QByteArray bytes{file.readAll()};
    return [[NSImage alloc] initWithData:bytes.toNSData()];
}

NSAlertStyle alertStyle(qint32 style)
{
    switch (style) {
    case 1:
        return NSAlertStyleWarning;
    case 2:
        return NSAlertStyleCritical;
    default:
        return NSAlertStyleInformational;
    }
}

qint32 buttonIndex(NSModalResponse response)
{
    return static_cast<qint32>(response - NSAlertFirstButtonReturn);
}

} // namespace

namespace rask::nativedialogs
{

void showAboutPanel(const QString &applicationName, const QString &version, const QString &copyright)
{
    NSMutableDictionary<NSAboutPanelOptionKey, id> *const options{[NSMutableDictionary dictionary]};
    if (!applicationName.isEmpty()) {
        options[NSAboutPanelOptionApplicationName] = applicationName.toNSString();
    }
    if (!version.isEmpty()) {
        // The panel shows "Version <ApplicationVersion> (<Version>)"; one string reads better.
        options[NSAboutPanelOptionApplicationVersion] = version.toNSString();
        options[NSAboutPanelOptionVersion] = @"";
    }
    if (!copyright.isEmpty()) {
        options[@"Copyright"] = copyright.toNSString();
    }
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanelWithOptions:options];
}

void showAboutQt()
{
    NSAlert *const alert{[[NSAlert alloc] init]};
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setMessageText:@"About Qt"];
    [alert setInformativeText:
               [NSString stringWithFormat:
                             @"This program uses Qt version %s.\n\n"
                             @"Qt is a C++ toolkit for cross-platform application development.\n\n"
                             @"Qt provides single-source portability across major desktop, embedded, and mobile "
                             @"platforms.\n\n"
                             @"Qt is available under commercial and GNU (L)GPL licenses. See https://qt.io/licensing "
                             @"for details.\n\n"
                             @"Copyright © The Qt Company Ltd. and other contributors.\n"
                             @"Qt and the Qt logo are trademarks of The Qt Company Ltd.\n"
                             @"Qt is developed as an open source project. See https://qt.io for more information.",
                             qVersion()]];
    NSImage *const logo{imageFromResource(QStringLiteral(":/qt/qml/Rask/Dialogs/qtlogo-64.png"))};
    if (logo != nil) {
        [alert setIcon:logo];
    }
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

void showAlert(
    QWindow *window,
    qint32 style,
    const QString &text,
    const QString &informativeText,
    const QStringList &buttons,
    const std::function<void(qint32 button)> &done
)
{
    NSAlert *const alert{[[NSAlert alloc] init]};
    [alert setAlertStyle:alertStyle(style)];
    [alert setMessageText:text.toNSString()];
    [alert setInformativeText:informativeText.toNSString()];
    // AppKit maps Return to the first button, Escape to "Cancel" and ⌘D to "Don't Save".
    std::ranges::for_each(buttons, [alert](const QString &title) { [alert addButtonWithTitle:title.toNSString()]; });

    NSWindow *const parent{nsWindow(window)};
    if (parent == nil) {
        done(buttonIndex([alert runModal]));
        return;
    }
    // The sheet answers after this returns. A block captures a C++ reference
    // as a reference, so it must capture a copy: a local, copied into the block.
    const std::function<void(qint32 button)> callback{done};
    [alert beginSheetModalForWindow:parent
                  completionHandler:^(NSModalResponse response) {
                    callback(buttonIndex(response));
                  }];
}

} // namespace rask::nativedialogs
