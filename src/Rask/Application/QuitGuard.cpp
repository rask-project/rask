#include "QuitGuard.h"

#include <QCoreApplication>
#include <QEvent>

namespace rask
{

QuitGuard::QuitGuard(QObject *parent) : QObject(parent)
{
    QCoreApplication::instance()->installEventFilter(this);
}

QuitGuard::~QuitGuard()
{
    if (QCoreApplication::instance() != nullptr) {
        QCoreApplication::instance()->removeEventFilter(this);
    }
}

void QuitGuard::setEnabled(bool enabled)
{
    if (this->enabled() == enabled) {
        return;
    }
    m_flags = enabled ? (m_flags | Enabled) : (m_flags & ~Enabled);
    emit enabledChanged();
}

void QuitGuard::quit()
{
    if (!quitting()) {
        m_flags |= Quitting;
        emit quittingChanged();
    }
    QCoreApplication::quit();
}

bool QuitGuard::eventFilter(QObject *watched, QEvent *event)
{
    // The system's request (applicationShouldTerminate) reaches the
    // application as a spontaneous Quit event; ignoring it cancels the
    // termination. The one Qt posts after the last window closed is not.
    if (watched != QCoreApplication::instance() || event->type() != QEvent::Quit || !event->spontaneous() ||
        !enabled() || quitting()) {
        return QObject::eventFilter(watched, event);
    }
    event->ignore();
    emit quitRequested();
    return true;
}

} // namespace rask
