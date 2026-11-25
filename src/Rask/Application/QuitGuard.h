#pragma once

#include <Rask/Application/raskapplication_export.h>

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// Lets the app ask before quitting. While enabled, a request to quit (⌘Q,
// Quit in the Dock, logging out) emits quitRequested() instead of closing
// the windows; the app reviews what it must (unsaved documents, in every
// window) and calls quit() to go ahead, or does nothing to stay.
class RASK_APPLICATION_EXPORT QuitGuard : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    // True once quit() was called: windows close without asking again.
    Q_PROPERTY(bool quitting READ quitting NOTIFY quittingChanged)
public:
    explicit QuitGuard(QObject *parent = nullptr);
    ~QuitGuard() override;

    [[nodiscard]] bool enabled() const noexcept { return (m_flags & Enabled) != 0U; }
    void setEnabled(bool enabled);
    [[nodiscard]] bool quitting() const noexcept { return (m_flags & Quitting) != 0U; }

    // Closes every window and quits.
    Q_INVOKABLE void quit();

signals:
    void enabledChanged();
    void quittingChanged();
    void quitRequested();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    static constexpr quint64 Enabled{1U << 0U};
    static constexpr quint64 Quitting{1U << 1U};

    quint64 m_flags{Enabled};
};

} // namespace rask
