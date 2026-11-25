#pragma once

#include <Rask/Window/raskwindow_export.h>

#include <QColor>
#include <QObject>
#include <QPointer>
#include <QUrl>
#include <QWindow>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// A translucent, blurred window with the content under the title bar.
//
// The QML window sets `flags: Qt.Window | Qt.ExpandedClientAreaHint |
// Qt.NoTitleBarBackgroundHint` and `color: "transparent"`, and starts its own
// title-bar content after `leadingInset` (the window buttons). The native
// window follows the application's appearance (Rask.Platform's Appearance).
class RASK_WINDOW_EXPORT NativeWindow : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QWindow *window READ window WRITE setWindow NOTIFY windowChanged)
    // The tint under the content and its opacity (also the blur's).
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(qreal alpha READ alpha WRITE setAlpha NOTIFY alphaChanged)
    Q_PROPERTY(bool blur READ blur WRITE setBlur NOTIFY blurChanged)
    // An empty unified toolbar: the taller title bar with vertically centred
    // window buttons. Turn it off in full screen.
    Q_PROPERTY(bool unifiedToolbar READ unifiedToolbar WRITE setUnifiedToolbar NOTIFY unifiedToolbarChanged)
    // False while QML drags something in the title bar area.
    Q_PROPERTY(bool movable READ movable WRITE setMovable NOTIFY movableChanged)
    // Right edge of the window buttons, in the window's coordinates.
    Q_PROPERTY(qreal leadingInset READ leadingInset NOTIFY leadingInsetChanged)
    // The file the window shows (its icon and path in the Window menu, Mission
    // Control); empty for none.
    Q_PROPERTY(QUrl representedFile READ representedFile WRITE setRepresentedFile NOTIFY representedFileChanged)
    // Unsaved changes: the dot in the close button.
    Q_PROPERTY(bool documentEdited READ documentEdited WRITE setDocumentEdited NOTIFY documentEditedChanged)
public:
    explicit NativeWindow(QObject *parent = nullptr);

    [[nodiscard]] QWindow *window() const { return m_window; }
    void setWindow(QWindow *window);
    [[nodiscard]] QColor color() const { return QColor::fromRgba(m_color); }
    void setColor(const QColor &color);
    [[nodiscard]] qreal alpha() const noexcept { return m_alpha; }
    void setAlpha(qreal alpha);
    [[nodiscard]] bool blur() const noexcept { return hasFlag(Blur); }
    void setBlur(bool blur);
    [[nodiscard]] bool unifiedToolbar() const noexcept { return hasFlag(UnifiedToolbar); }
    void setUnifiedToolbar(bool unifiedToolbar);
    [[nodiscard]] bool movable() const noexcept { return hasFlag(Movable); }
    void setMovable(bool movable);
    [[nodiscard]] qreal leadingInset() const noexcept { return m_leadingInset; }
    [[nodiscard]] QUrl representedFile() const { return m_representedFile; }
    void setRepresentedFile(const QUrl &file);
    [[nodiscard]] bool documentEdited() const noexcept { return hasFlag(DocumentEdited); }
    void setDocumentEdited(bool edited);

    // A double click on empty title-bar space: the system's action (zoom,
    // minimize or nothing, per System Settings).
    Q_INVOKABLE void titleBarDoubleClicked() const;

signals:
    void windowChanged();
    void colorChanged();
    void alphaChanged();
    void blurChanged();
    void unifiedToolbarChanged();
    void movableChanged();
    void leadingInsetChanged();
    void representedFileChanged();
    void documentEditedChanged();

private:
    static constexpr quint32 Blur{1U << 0U};
    static constexpr quint32 UnifiedToolbar{1U << 1U};
    static constexpr quint32 Movable{1U << 2U};
    static constexpr quint32 DocumentEdited{1U << 3U};

    [[nodiscard]] bool hasFlag(quint32 flag) const noexcept { return (m_flags & flag) != 0U; }
    bool setFlag(quint32 flag, bool on) noexcept;
    [[nodiscard]] WId nativeId() const;
    void apply();

    QPointer<QWindow> m_window;
    QUrl m_representedFile;
    qreal m_alpha{0.8};
    qreal m_leadingInset{0.0};
    QRgb m_color{0xff000000U};
    quint32 m_flags{Blur | UnifiedToolbar | Movable};
};

} // namespace rask
