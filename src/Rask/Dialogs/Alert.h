#pragma once

#include <Rask/Dialogs/raskdialogs_export.h>

#include <QObject>
#include <QPointer>
#include <QString>
#include <QStringList>
#include <QWindow>
#include <QtQmlIntegration/qqmlintegration.h>

#include <utility>

namespace rask
{

// A native alert (NSAlert). With `window` it opens as a sheet on that window,
// otherwise app-modal. `finished(button)` reports the index of the chosen
// button in `buttons`. AppKit maps Return to the first button, Escape to a
// "Cancel" button and ⌘D to "Don't Save". Where `supported` is false nothing
// is shown and `finished(-1)` is emitted: use a QML dialog there.
class RASK_DIALOGS_EXPORT Alert : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Style style READ style WRITE setStyle NOTIFY styleChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString informativeText READ informativeText WRITE setInformativeText NOTIFY informativeTextChanged)
    Q_PROPERTY(QStringList buttons READ buttons WRITE setButtons NOTIFY buttonsChanged)
    Q_PROPERTY(QWindow *window READ window WRITE setWindow NOTIFY windowChanged)
    // The button chosen last time, -1 before the first answer.
    Q_PROPERTY(qint32 result READ result NOTIFY finished)
    Q_PROPERTY(bool supported READ supported CONSTANT)
public:
    enum class Style : quint8 {
        Informational,
        Warning,
        Critical
    };
    Q_ENUM(Style)

    explicit Alert(QObject *parent = nullptr);

    [[nodiscard]] Style style() const noexcept { return static_cast<Style>(m_style); }
    void setStyle(Style style);
    [[nodiscard]] QString text() const { return m_text; }
    void setText(const QString &text);
    [[nodiscard]] QString informativeText() const { return m_informativeText; }
    void setInformativeText(const QString &informativeText);
    [[nodiscard]] QStringList buttons() const { return m_buttons; }
    void setButtons(const QStringList &buttons);
    [[nodiscard]] QWindow *window() const { return m_window; }
    void setWindow(QWindow *window);
    [[nodiscard]] qint32 result() const noexcept { return m_result; }
    [[nodiscard]] static bool supported() noexcept;

    Q_INVOKABLE void open();

signals:
    void styleChanged();
    void textChanged();
    void informativeTextChanged();
    void buttonsChanged();
    void windowChanged();
    void finished(qint32 button);

private:
    QPointer<QWindow> m_window;
    QString m_text;
    QString m_informativeText;
    QStringList m_buttons{QStringLiteral("OK")};
    // 32 bits next to m_result, so the layout has no padding.
    quint32 m_style{std::to_underlying(Style::Informational)};
    qint32 m_result{-1};
};

} // namespace rask
