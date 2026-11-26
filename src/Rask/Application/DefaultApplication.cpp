#include "DefaultApplication.h"
#include "MacDefaultApplication_p.h"

#include <algorithm>
#include <functional>
#include <iterator>

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
    if (types.isEmpty()) {
        return false;
    }
    // Only the types another app opens: macOS asks the user about each of
    // those (it cannot be batched), so asking again for the rest would repeat it.
    QStringList others;
    std::ranges::copy_if(types, std::back_inserter(others), std::not_fn(&macdefault::opensWithThisApp));
    // Every type, even after one is refused.
    return others.isEmpty() || std::ranges::count_if(others, &macdefault::setThisApp) > 0;
}

} // namespace rask
