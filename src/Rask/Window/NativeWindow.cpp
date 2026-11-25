#include "NativeWindow.h"

#include "MacWindowEffects_p.h"

#include <QTimer>

namespace rask
{

NativeWindow::NativeWindow(QObject *parent) : QObject(parent) {}

void NativeWindow::setWindow(QWindow *window)
{
    if (m_window == window) {
        return;
    }
    if (m_window != nullptr) {
        disconnect(m_window, nullptr, this, nullptr);
    }
    m_window = window;
    emit windowChanged();

    if (m_window == nullptr) {
        return;
    }
    // Hiding the window drops its NSWindow; the one created on show starts unstyled.
    connect(m_window, &QWindow::visibleChanged, this, [this](bool visible) {
        if (visible) {
            QTimer::singleShot(0, this, &NativeWindow::apply);
        }
    });
    // Deferred so the QML window finishes setting its flags before winId()
    // creates the native window.
    QTimer::singleShot(0, this, &NativeWindow::apply);
}

void NativeWindow::setColor(const QColor &color)
{
    if (m_color == color.rgba()) {
        return;
    }
    m_color = color.rgba();
    emit colorChanged();
    apply();
}

void NativeWindow::setAlpha(qreal alpha)
{
    if (qFuzzyCompare(m_alpha, alpha)) {
        return;
    }
    m_alpha = alpha;
    emit alphaChanged();
    apply();
}

void NativeWindow::setBlur(bool blur)
{
    if (setFlag(Blur, blur)) {
        emit blurChanged();
        apply();
    }
}

void NativeWindow::setUnifiedToolbar(bool unifiedToolbar)
{
    if (setFlag(UnifiedToolbar, unifiedToolbar)) {
        emit unifiedToolbarChanged();
        apply();
    }
}

void NativeWindow::setMovable(bool movable)
{
    if (setFlag(Movable, movable)) {
        emit movableChanged();
        macwindow::setMovable(nativeId(), movable);
    }
}

void NativeWindow::setRepresentedFile(const QUrl &file)
{
    if (m_representedFile == file) {
        return;
    }
    m_representedFile = file;
    emit representedFileChanged();
    macwindow::setRepresentedFile(nativeId(), m_representedFile.toLocalFile());
}

void NativeWindow::setDocumentEdited(bool edited)
{
    if (setFlag(DocumentEdited, edited)) {
        emit documentEditedChanged();
        macwindow::setDocumentEdited(nativeId(), edited);
    }
}

void NativeWindow::titleBarDoubleClicked() const
{
    macwindow::performTitleBarDoubleClick(nativeId());
}

bool NativeWindow::setFlag(quint32 flag, bool on) noexcept
{
    if (hasFlag(flag) == on) {
        return false;
    }
    m_flags = on ? (m_flags | flag) : (m_flags & ~flag);
    return true;
}

WId NativeWindow::nativeId() const
{
    // winId() would create the native window; before it is shown there is nothing to style.
    return (m_window != nullptr && m_window->handle() != nullptr) ? m_window->winId() : WId{0};
}

void NativeWindow::apply()
{
    const WId winId{nativeId()};
    if (winId == 0U) {
        return;
    }
    macwindow::apply(winId, color(), m_alpha, blur(), unifiedToolbar());
    macwindow::setResizable(winId, m_window->minimumSize() != m_window->maximumSize());
    macwindow::setMovable(winId, movable());
    macwindow::setRepresentedFile(winId, m_representedFile.toLocalFile());
    macwindow::setDocumentEdited(winId, documentEdited());

    const qreal inset{macwindow::windowButtonsTrailingEdge(winId)};
    if (qFuzzyCompare(m_leadingInset, inset)) {
        return;
    }
    m_leadingInset = inset;
    emit leadingInsetChanged();
}

} // namespace rask
