#include "DefaultApplication.h"
#include "MacDefaultApplication_p.h"

#include <algorithm>

namespace rask
{

DefaultApplication::DefaultApplication(QObject *parent) : QObject(parent) {}

bool DefaultApplication::isDefault(const QString &documentType)
{
    const QStringList types{macdefault::contentTypes(documentType)};
    return !types.isEmpty() && std::ranges::all_of(types, &macdefault::opensWithThisApp);
}

bool DefaultApplication::makeDefault(const QString &documentType)
{
    const QStringList types{macdefault::contentTypes(documentType)};
    // Every type, even after one is refused.
    return std::ranges::count_if(types, &macdefault::setThisApp) > 0;
}

} // namespace rask
