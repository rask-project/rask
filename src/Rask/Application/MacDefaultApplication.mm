#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

#include "MacDefaultApplication_p.h"

namespace rask::macdefault
{

QStringList contentTypes(const QString &documentType)
{
    __block QStringList types;
    NSArray *const documentTypes = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleDocumentTypes"];
    NSString *const name = documentType.toNSString();
    [documentTypes enumerateObjectsUsingBlock:^(NSDictionary *entry, NSUInteger index, BOOL *stop) {
      Q_UNUSED(index);
      Q_UNUSED(stop);
      if (![entry[@"CFBundleTypeName"] isEqualToString:name]) {
          return;
      }
      [entry[@"LSItemContentTypes"]
          enumerateObjectsUsingBlock:^(NSString *identifier, NSUInteger typeIndex, BOOL *typeStop) {
            Q_UNUSED(typeIndex);
            Q_UNUSED(typeStop);
            types.emplace_back(QString::fromNSString(identifier));
          }];
    }];
    return types;
}

bool opensWithThisApp(const QString &contentType)
{
    UTType *const type = [UTType typeWithIdentifier:contentType.toNSString()];
    if (type == nil) {
        return false;
    }
    NSURL *const app = [NSWorkspace.sharedWorkspace URLForApplicationToOpenContentType:type];
    return app != nil && [[NSBundle bundleWithURL:app].bundleIdentifier
                             caseInsensitiveCompare:NSBundle.mainBundle.bundleIdentifier] == NSOrderedSame;
}

bool setThisApp(const QString &contentType)
{
    // NSWorkspace's setDefaultApplicationAtURL:toOpenContentType: asks the
    // user to confirm each type; this does not.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    const OSStatus status{LSSetDefaultRoleHandlerForContentType(
        (__bridge CFStringRef) contentType.toNSString(),
        kLSRolesAll,
        (__bridge CFStringRef) NSBundle.mainBundle.bundleIdentifier
    )};
#pragma clang diagnostic pop
    return status == noErr;
}

} // namespace rask::macdefault
