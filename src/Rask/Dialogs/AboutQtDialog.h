#pragma once

#include <Rask/Dialogs/raskdialogs_export.h>

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The native "About Qt" alert: the Qt version in use, its licensing and the
// Qt logo.
class RASK_DIALOGS_EXPORT AboutQtDialog : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit AboutQtDialog(QObject *parent = nullptr);

    Q_INVOKABLE void open() const;
};

} // namespace rask
