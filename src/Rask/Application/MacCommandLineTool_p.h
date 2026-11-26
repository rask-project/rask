#pragma once

#include <QString>

// Writing to /usr/local/bin with an administrator's password (MacCommandLineTool.mm).
namespace rask::maccommandline
{

// Links `link` to `target` (making its folder if needed); false when the user cancels or it fails.
bool linkAsAdministrator(const QString &target, const QString &link);

} // namespace rask::maccommandline
