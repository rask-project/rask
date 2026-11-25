#pragma once

#include <Rask/Application/raskapplication_export.h>

#include <QList>
#include <QObject>
#include <QUrl>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The files the system asks the app to open: Finder's "Open With", files
// dropped on the Dock icon, a document chosen in the Dock menu. Files that
// arrive before anything listens (at launch) wait for the first connection.
class RASK_APPLICATION_EXPORT FileOpenHandler : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    explicit FileOpenHandler(QObject *parent = nullptr);
    ~FileOpenHandler() override;

signals:
    // The files of one request, in order.
    void filesOpened(const QList<QUrl> &files);

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;
    void connectNotify(const QMetaMethod &signal) override;

private:
    void deliver();

    QList<QUrl> m_pending;
};

} // namespace rask
