#pragma once

#include <QString>

// NSDocumentController's recent documents (MacRecentDocuments.mm).
namespace rask::macrecent
{

void note(const QString &path);
void clear();

} // namespace rask::macrecent
