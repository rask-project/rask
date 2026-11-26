#pragma once

#include <Rask/Application/raskapplication_export.h>

#include <QObject>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The app as the one that opens a kind of file on a double click: the
// content types of one of its document types (CFBundleDocumentTypes, by
// CFBundleTypeName). The change takes effect a few seconds later. For each
// type another app opens, macOS asks the user to confirm, one dialog per
// type: keep the document type to the few that matter.
class RASK_APPLICATION_EXPORT DefaultApplication : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit DefaultApplication(QObject *parent = nullptr);

    // Every content type of `documentType` opens with this app.
    Q_INVOKABLE [[nodiscard]] static bool isDefault(const QString &documentType);
    // Asks only for the types that open with another app. False when the
    // bundle has no such document type or the system refused them all.
    Q_INVOKABLE static bool makeDefault(const QString &documentType);
};

} // namespace rask
