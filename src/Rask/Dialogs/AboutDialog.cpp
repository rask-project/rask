#include "AboutDialog.h"

#include "NativeDialogs_p.h"

namespace rask
{

AboutDialog::AboutDialog(QObject *parent) : QObject(parent) {}

void AboutDialog::setApplicationName(const QString &applicationName)
{
    if (m_applicationName == applicationName) {
        return;
    }
    m_applicationName = applicationName;
    emit applicationNameChanged();
}

void AboutDialog::setVersion(const QString &version)
{
    if (m_version == version) {
        return;
    }
    m_version = version;
    emit versionChanged();
}

void AboutDialog::setCopyright(const QString &copyright)
{
    if (m_copyright == copyright) {
        return;
    }
    m_copyright = copyright;
    emit copyrightChanged();
}

void AboutDialog::open() const
{
    nativedialogs::showAboutPanel(m_applicationName, m_version, m_copyright);
}

} // namespace rask
