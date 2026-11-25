#pragma once

#include <QColor>
#include <QWindow>

// The native side of NativeWindow: AppKit in MacWindowEffects.mm, no-ops in
// MacWindowEffects_stub.cpp on other platforms.
namespace rask::macwindow
{

[[nodiscard]] bool supported() noexcept;
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

} // namespace rask::macwindow
