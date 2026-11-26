#pragma once

#include <Rask/Application/raskapplication_export.h>

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// A command for the Terminal, as VS Code's `code`: a link in /usr/local/bin
// to an executable the app bundles in Contents/Resources/bin/<name>.
class RASK_APPLICATION_EXPORT CommandLineTool : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit CommandLineTool(QObject *parent = nullptr);

    // /usr/local/bin/<name> links to this bundle's tool.
    Q_INVOKABLE [[nodiscard]] static bool isInstalled(const QString &name);
    // Links it, replacing a link of the same name (not a file), with an
    // administrator's password when /usr/local/bin is not writable. False
    // when the bundle has no such tool, the user cancels or the link fails.
    Q_INVOKABLE static bool install(const QString &name);
};

} // namespace rask
