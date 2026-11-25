#pragma once

#include <Rask/Dialogs/raskdialogs_export.h>

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The "About Qt" alert, native on macOS: the Qt version in use, its
// licensing and the Qt logo.
class RASK_DIALOGS_EXPORT AboutQtDialog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool supported READ supported CONSTANT)
public:
    explicit AboutQtDialog(QObject *parent = nullptr);

    [[nodiscard]] static bool supported() noexcept;

    Q_INVOKABLE void open() const;
};

} // namespace rask
