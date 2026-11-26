#pragma once

#include <QString>
#include <QStringList>

// Launch Services' default apps (MacDefaultApplication.mm).
namespace rask::macdefault
{

// The LSItemContentTypes of the bundle's document type named `documentType`.
[[nodiscard]] QStringList contentTypes(const QString &documentType);
[[nodiscard]] bool opensWithThisApp(const QString &contentType);
bool setThisApp(const QString &contentType);

} // namespace rask::macdefault
