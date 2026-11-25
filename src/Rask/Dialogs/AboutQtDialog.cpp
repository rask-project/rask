#include "AboutQtDialog.h"

#include "NativeDialogs_p.h"

namespace rask
{

AboutQtDialog::AboutQtDialog(QObject *parent) : QObject(parent) {}

bool AboutQtDialog::supported() noexcept
{
    return nativedialogs::supported();
}

void AboutQtDialog::open() const
{
    nativedialogs::showAboutQt();
}

} // namespace rask
