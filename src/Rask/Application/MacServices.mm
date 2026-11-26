#import <AppKit/AppKit.h>

#include "MacServices_p.h"

#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>

#include <utility>

namespace
{

// Tests run offscreen, outside an app bundle: no provider there.
bool available()
{
    return QGuiApplication::platformName() == QLatin1String("cocoa");
}

// A path sent as text may start with ~ or be a file:// URL; empty unless something is there.
QUrl existingFile(const QString &text)
{
    QString path{text.trimmed()};
    if (path.startsWith(QLatin1String("file://"))) {
        path = QUrl{path}.toLocalFile();
    } else if (path == QLatin1String("~") || path.startsWith(QLatin1String("~/"))) {
        path = QDir::homePath() + path.mid(1);
    }
    if (path.isEmpty() || !QFileInfo::exists(path)) {
        return {};
    }
    return QUrl::fromLocalFile(QFileInfo{path}.absoluteFilePath());
}

} // namespace

@interface RaskServicesProvider : NSObject
- (instancetype)initWithOpen:(std::function<void(const QList<QUrl> &)>)open;
- (void)openFiles:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error;
@end

@implementation RaskServicesProvider {
    std::function<void(const QList<QUrl> &)> _open;
}

- (instancetype)initWithOpen:(std::function<void(const QList<QUrl> &)>)open
{
    self = [super init];
    if (self != nil) {
        _open = std::move(open);
    }
    return self;
}

- (void)openFiles:(NSPasteboard *)pasteboard userData:(NSString *)userData error:(NSString **)error
{
    Q_UNUSED(userData);
    Q_UNUSED(error);
    __block QList<QUrl> files;
    NSArray<NSURL *> *const urls = [pasteboard readObjectsForClasses:@[ [NSURL class] ]
                                                             options:@{NSPasteboardURLReadingFileURLsOnlyKey : @YES}];
    [urls enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger index, BOOL *stop) {
      Q_UNUSED(index);
      Q_UNUSED(stop);
      files.emplace_back(QUrl::fromLocalFile(QString::fromNSString(url.path)));
    }];
    // A path selected as text (NSRequiredContext FilePath).
    if (files.isEmpty()) {
        if (NSString *const text = [pasteboard stringForType:NSPasteboardTypeString]) {
            if (const QUrl file{existingFile(QString::fromNSString(text))}; !file.isEmpty()) {
                files.emplace_back(file);
            }
        }
    }
    if (files.isEmpty()) {
        return;
    }
    // A Service runs without making the app the active one.
    [NSApp activate];
    _open(files);
}

@end

namespace rask::macservices
{

void install(std::function<void(const QList<QUrl> &)> open)
{
    if (!available()) {
        return;
    }
    // NSApp keeps the provider.
    [NSApp setServicesProvider:[[RaskServicesProvider alloc] initWithOpen:std::move(open)]];
    NSUpdateDynamicServices();
}

void remove()
{
    if (!available()) {
        return;
    }
    [NSApp setServicesProvider:nil];
}

} // namespace rask::macservices
