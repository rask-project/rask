#pragma once

#include <Rask/Application/raskapplication_export.h>

#include <QList>
#include <QObject>
#include <QUrl>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The documents opened lately, most recent first, for an "Open Recent" menu.
// Kept in QSettings (`recentDocuments`) and given to the system as well,
// which lists them in the Dock menu.
class RASK_APPLICATION_EXPORT RecentDocuments : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QList<QUrl> files READ files NOTIFY filesChanged)
public:
    explicit RecentDocuments(QObject *parent = nullptr);

    [[nodiscard]] static QList<QUrl> files();
    // Moves `file` to the top (local files only).
    Q_INVOKABLE void add(const QUrl &file);
    Q_INVOKABLE void clear();

    static constexpr qsizetype maximumCount{10};

signals:
    void filesChanged();
};

} // namespace rask
