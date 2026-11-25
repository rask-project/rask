#pragma once

#include <QColor>
#include <QRectF>
#include <QString>
#include <QWindow>

// The native side of NativeWindow and GlassEffect (AppKit, MacWindowEffects.mm).
namespace rask::macwindow
{

// Hidden title, transparent tinted background, optional blur under the whole
// frame and optional empty unified toolbar with the Qt content above it.
void apply(WId winId, const QColor &color, qreal alpha, bool blur, bool unifiedToolbar);
// Right edge of the close/minimize/zoom buttons in the content's coordinates.
[[nodiscard]] qreal windowButtonsTrailingEdge(WId winId);
// Qt keeps every window resizable and relies on size limits, which the
// expanded title bar escapes.
void setResizable(WId winId, bool resizable);
void setMovable(WId winId, bool movable);
void performTitleBarDoubleClick(WId winId);

// Liquid Glass (macOS 26+): NSGlassEffectViews behind the Qt content view,
// above the window blur, so QML draws on top of real glass. Each view is
// addressed by a caller-chosen identifier.
[[nodiscard]] bool glassSupported() noexcept;
[[nodiscard]] bool createGlassView(WId winId, const QString &identifier);
// `sceneRect` is in QML scene (content view) coordinates.
void updateGlassView(
    WId winId,
    const QString &identifier,
    const QRectF &sceneRect,
    qreal cornerRadius,
    const QColor &tint,
    qreal alpha,
    bool clearStyle
);
void destroyGlassView(WId winId, const QString &identifier);

} // namespace rask::macwindow
