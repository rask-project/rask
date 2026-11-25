#include "Alert.h"

#include "NativeDialogs_p.h"

#include <utility>

namespace rask
{

Alert::Alert(QObject *parent) : QObject(parent) {}

void Alert::setStyle(Style style)
{
    if (this->style() == style) {
        return;
    }
    m_style = std::to_underlying(style);
    emit styleChanged();
}

void Alert::setText(const QString &text)
{
    if (m_text == text) {
        return;
    }
    m_text = text;
    emit textChanged();
}

void Alert::setInformativeText(const QString &informativeText)
{
    if (m_informativeText == informativeText) {
        return;
    }
    m_informativeText = informativeText;
    emit informativeTextChanged();
}

void Alert::setButtons(const QStringList &buttons)
{
    if (m_buttons == buttons) {
        return;
    }
    m_buttons = buttons;
    emit buttonsChanged();
}

void Alert::setWindow(QWindow *window)
{
    if (m_window == window) {
        return;
    }
    m_window = window;
    emit windowChanged();
}

bool Alert::supported() noexcept
{
    return nativedialogs::supported();
}

void Alert::open()
{
    // A sheet answers after this object may be gone.
    const QPointer<Alert> self{this};
    nativedialogs::showAlert(
        m_window,
        static_cast<qint32>(m_style),
        m_text,
        m_informativeText,
        m_buttons,
        [self](qint32 button) {
            if (self == nullptr) {
                return;
            }
            self->m_result = button;
            emit self->finished(button);
        }
    );
}

} // namespace rask
