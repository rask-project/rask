#import <AppKit/AppKit.h>
#import <Sparkle/Sparkle.h>

#include "UpdaterNative_p.h"

#include <utility>

// Sparkle asks it which channels to look in, and reports the end of each check.
@interface RaskUpdaterDelegate : NSObject <SPUUpdaterDelegate>
- (instancetype)initWithAllowBeta:(std::function<bool()>)allowBeta checkFinished:(std::function<void()>)checkFinished;
@end

@implementation RaskUpdaterDelegate {
    std::function<bool()> _allowBeta;
    std::function<void()> _checkFinished;
}

- (instancetype)initWithAllowBeta:(std::function<bool()>)allowBeta checkFinished:(std::function<void()>)checkFinished
{
    self = [super init];
    if (self != nil) {
        _allowBeta = std::move(allowBeta);
        _checkFinished = std::move(checkFinished);
    }
    return self;
}

- (NSSet<NSString *> *)allowedChannelsForUpdater:(SPUUpdater *)updater
{
    (void) updater;
    // The default channel (stable releases) is always included.
    return _allowBeta() ? [NSSet setWithObject:@"beta"] : [NSSet set];
}

- (void)updater:(SPUUpdater *)updater
    didFinishUpdateCycleForUpdateCheck:(SPUUpdateCheck)updateCheck
                                 error:(nullable NSError *)error
{
    (void) updater;
    (void) updateCheck;
    (void) error;
    _checkFinished();
}

@end

namespace
{

// Created once and never released (CFBridgingRetain): AppKit may still call
// them while the app quits, after static destructors have run. Sparkle keeps
// its delegate weak, so the delegate is retained here too.
struct Sparkle {
    CFTypeRef controller{nullptr};
    CFTypeRef delegate{nullptr};
};

Sparkle &sparkle()
{
    static Sparkle instance;
    return instance;
}

SPUStandardUpdaterController *controller()
{
    return (__bridge SPUStandardUpdaterController *) sparkle().controller;
}

// "Check for Updates…" goes in the app menu after the About items. Qt only
// moves the items it recognizes (About, Settings, Quit) there; any other item
// of a QML menu titled after the app would show up in a second app-named menu.
void addCheckForUpdatesItem(SPUStandardUpdaterController *updaterController)
{
    NSMenu *const appMenu{[[[NSApp mainMenu] itemAtIndex:0] submenu]};
    if (appMenu == nil) {
        return;
    }
    const NSUInteger lastAbout{[appMenu.itemArray
        indexOfObjectWithOptions:NSEnumerationReverse
                     passingTest:^BOOL(NSMenuItem *candidate, NSUInteger, BOOL *) {
                       return [candidate.title hasPrefix:@"About"];
                     }]};
    const NSInteger index{lastAbout == NSNotFound ? 0 : static_cast<NSInteger>(lastAbout) + 1};
    NSMenuItem *const item
    {
        [[NSMenuItem alloc] initWithTitle:@"Check for Updates…" action:@selector(checkForUpdates:) keyEquivalent:@""]
    };
    // The controller enables it only while a check can start.
    item.target = updaterController;
    [appMenu insertItem:item atIndex:index];
}

} // namespace

namespace rask::updaternative
{

bool configured()
{
    NSDictionary *const info{[[NSBundle mainBundle] infoDictionary]};
    const id feed{info[@"SUFeedURL"]};
    const id key{info[@"SUPublicEDKey"]};
    return [feed isKindOfClass:[NSString class]] && [feed length] > 0 && [key isKindOfClass:[NSString class]] &&
           [key length] > 0;
}

void start(std::function<bool()> allowBeta, std::function<void()> checkFinished)
{
    if (started() || !configured()) {
        return;
    }
    RaskUpdaterDelegate *const delegate{[[RaskUpdaterDelegate alloc] initWithAllowBeta:std::move(allowBeta)
                                                                         checkFinished:std::move(checkFinished)]};
    SPUStandardUpdaterController *const created{[[SPUStandardUpdaterController alloc] initWithStartingUpdater:YES
                                                                                              updaterDelegate:delegate
                                                                                           userDriverDelegate:nil]};
    sparkle().delegate = CFBridgingRetain(delegate);
    sparkle().controller = CFBridgingRetain(created);
    addCheckForUpdatesItem(created);
}

bool started()
{
    return sparkle().controller != nullptr;
}

void checkForUpdates()
{
    [controller() checkForUpdates:nil];
}

bool automaticChecks()
{
    return started() && controller().updater.automaticallyChecksForUpdates;
}

void setAutomaticChecks(bool enabled)
{
    controller().updater.automaticallyChecksForUpdates = enabled;
}

bool automaticDownloads()
{
    return started() && controller().updater.automaticallyDownloadsUpdates;
}

void setAutomaticDownloads(bool enabled)
{
    controller().updater.automaticallyDownloadsUpdates = enabled;
}

void resetUpdateCycle()
{
    [controller().updater resetUpdateCycleAfterShortDelay];
}

QDateTime lastCheck()
{
    NSDate *const date{controller().updater.lastUpdateCheckDate};
    return date != nil ? QDateTime::fromNSDate(date) : QDateTime{};
}

} // namespace rask::updaternative
