#include "NativeDialogs_p.h"

namespace rask::nativedialogs
{

bool supported() noexcept
{
    return false;
}

void showAboutPanel(const QString & /*applicationName*/, const QString & /*version*/, const QString & /*copyright*/) {}

void showAboutQt() {}

void showAlert(
    QWindow * /*window*/,
    qint32 /*style*/,
    const QString & /*text*/,
    const QString & /*informativeText*/,
    const QStringList & /*buttons*/,
    const std::function<void(qint32 button)> &done
)
{
    done(-1);
}

} // namespace rask::nativedialogs
