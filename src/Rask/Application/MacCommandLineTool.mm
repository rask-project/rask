#import <Foundation/Foundation.h>

#include "MacCommandLineTool_p.h"

#include <QFileInfo>

namespace rask::maccommandline
{

namespace
{

// `text` as one word for sh, inside an AppleScript string.
QString quoted(const QString &text)
{
    QString word{text};
    word.replace(QLatin1Char('\''), QStringLiteral("'\\''"));
    word = QLatin1Char('\'') + word + QLatin1Char('\'');
    word.replace(QLatin1Char('\\'), QStringLiteral("\\\\"));
    word.replace(QLatin1Char('"'), QStringLiteral("\\\""));
    return word;
}

} // namespace

bool linkAsAdministrator(const QString &target, const QString &link)
{
    // The system's password dialog: `do shell script` runs in this process.
    const QString command{QStringLiteral("mkdir -p %1 && ln -sfh %2 %3")
                              .arg(quoted(QFileInfo{link}.absolutePath()), quoted(target), quoted(link))};
    NSAppleScript *const script = [[NSAppleScript alloc]
        initWithSource:[NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges",
                                                  command.toNSString()]];
    NSDictionary *error = nil;
    return [script executeAndReturnError:&error] != nil;
}

} // namespace rask::maccommandline
