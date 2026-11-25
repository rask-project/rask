#pragma once

#include <Rask/Dialogs/raskdialogs_export.h>

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The system's About panel. Empty properties keep the panel's
// defaults, read from the bundle: CFBundleName, the version and
// NSHumanReadableCopyright.
class RASK_DIALOGS_EXPORT AboutDialog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString applicationName READ applicationName WRITE setApplicationName NOTIFY applicationNameChanged)
    // Shown as is, e.g. "Version 1.2.0 (abc1234)".
    Q_PROPERTY(QString version READ version WRITE setVersion NOTIFY versionChanged)
    Q_PROPERTY(QString copyright READ copyright WRITE setCopyright NOTIFY copyrightChanged)
public:
    explicit AboutDialog(QObject *parent = nullptr);

    [[nodiscard]] QString applicationName() const { return m_applicationName; }
    void setApplicationName(const QString &applicationName);
    [[nodiscard]] QString version() const { return m_version; }
    void setVersion(const QString &version);
    [[nodiscard]] QString copyright() const { return m_copyright; }
    void setCopyright(const QString &copyright);

    Q_INVOKABLE void open() const;

signals:
    void applicationNameChanged();
    void versionChanged();
    void copyrightChanged();

private:
    QString m_applicationName;
    QString m_version;
    QString m_copyright;
};

} // namespace rask
