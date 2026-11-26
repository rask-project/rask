#include "FileOpenHandler.h"
#include "MacServices_p.h"

#include <QCoreApplication>
#include <QFileOpenEvent>
#include <QMetaMethod>
#include <QTimer>

namespace rask
{

FileOpenHandler::FileOpenHandler(QObject *parent) : QObject(parent)
{
    QCoreApplication::instance()->installEventFilter(this);
    macservices::install([this](const QList<QUrl> &files) {
        for (const QUrl &file : files) {
            enqueue(file);
        }
    });
}

FileOpenHandler::~FileOpenHandler()
{
    macservices::remove();
    if (QCoreApplication::instance() != nullptr) {
        QCoreApplication::instance()->removeEventFilter(this);
    }
}

bool FileOpenHandler::eventFilter(QObject *watched, QEvent *event)
{
    if (watched != QCoreApplication::instance() || event->type() != QEvent::FileOpen) {
        return QObject::eventFilter(watched, event);
    }
    const QUrl url{static_cast<const QFileOpenEvent *>(event)->url()};
    if (!url.isEmpty()) {
        enqueue(url);
    }
    return true;
}

void FileOpenHandler::enqueue(const QUrl &file)
{
    // Several files of one request come one by one: deliver them together.
    if (m_pending.isEmpty()) {
        QTimer::singleShot(0, this, &FileOpenHandler::deliver);
    }
    m_pending.emplace_back(file);
}

void FileOpenHandler::connectNotify(const QMetaMethod &signal)
{
    if (signal == QMetaMethod::fromSignal(&FileOpenHandler::filesOpened) && !m_pending.isEmpty()) {
        QTimer::singleShot(0, this, &FileOpenHandler::deliver);
    }
}

void FileOpenHandler::deliver()
{
    if (m_pending.isEmpty() || !isSignalConnected(QMetaMethod::fromSignal(&FileOpenHandler::filesOpened))) {
        return;
    }
    emit filesOpened(std::exchange(m_pending, {}));
}

} // namespace rask
