#include "MacWindowEffects_p.h"

namespace rask::macwindow
{

bool supported() noexcept
{
    return false;
}

void apply(WId /*winId*/, const QColor & /*color*/, qreal /*alpha*/, bool /*blur*/, bool /*unifiedToolbar*/) {}

qreal windowButtonsTrailingEdge(WId /*winId*/)
{
    return 0.0;
}

void setResizable(WId /*winId*/, bool /*resizable*/) {}

void setMovable(WId /*winId*/, bool /*movable*/) {}

void performTitleBarDoubleClick(WId /*winId*/) {}

} // namespace rask::macwindow
