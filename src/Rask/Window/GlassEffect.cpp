#include "GlassEffect.h"

#include "MacWindowEffects_p.h"

#include <QUuid>

#include <algorithm>

namespace rask
{

GlassEffect::GlassEffect(QQuickItem *parent)
    : QQuickItem(parent)
    , m_identifier(QUuid::createUuid().toString(QUuid::WithoutBraces))
{}

GlassEffect::~GlassEffect()
{
    detach();
}

bool GlassEffect::supported() noexcept
{
    return macwindow::glassSupported();
}

void GlassEffect::setCornerRadius(qreal radius)
{
    if (qFuzzyCompare(m_cornerRadius, radius)) {
        return;
    }
    m_cornerRadius = radius;
    emit cornerRadiusChanged();
    markDirty();
}

void GlassEffect::setTint(const QColor &tint)
{
    if (m_tint == tint.rgba()) {
        return;
    }
    m_tint = tint.rgba();
    emit tintChanged();
    markDirty();
}

void GlassEffect::setClear(bool clear)
{
    if (m_clear == clear) {
        return;
    }
    m_clear = clear;
    emit clearChanged();
    markDirty();
}

void GlassEffect::itemChange(ItemChange change, const ItemChangeData &value)
{
    QQuickItem::itemChange(change, value);
    if (change == ItemSceneChange) {
        detach();
        attach(value.window);
    } else if (change == ItemVisibleHasChanged || change == ItemOpacityHasChanged) {
        markDirty();
    }
}

void GlassEffect::attach(QQuickWindow *window)
{
    if (window == nullptr || !supported()) {
        return;
    }
    m_window = window;
    // Ancestors can move this item without notifying it (e.g. animated tab
    // positions), so the scene geometry is re-checked on every animation tick.
    m_frameConnection = connect(window, &QQuickWindow::afterAnimating, this, &GlassEffect::sync);
    markDirty();
}

void GlassEffect::detach()
{
    disconnect(m_frameConnection);
    if (m_created && m_window != nullptr && m_window->handle() != nullptr) {
        macwindow::destroyGlassView(m_winId, m_identifier);
    }
    m_window.clear();
    m_created = false;
    m_winId = 0;
    m_lastRect = {};
    m_lastAlpha = 0U;
}

void GlassEffect::markDirty()
{
    m_dirty = true;
    if (m_window != nullptr) {
        m_window->update();
    }
}

qreal GlassEffect::effectiveOpacity() const
{
    qreal opacity{1.0};
    for (const QQuickItem *item{this}; item != nullptr; item = item->parentItem()) {
        opacity *= item->opacity();
    }
    return opacity;
}

void GlassEffect::sync()
{
    if (m_window == nullptr || m_window->handle() == nullptr) {
        return;
    }
    if (!m_created) {
        m_winId = m_window->winId();
        m_created = macwindow::createGlassView(m_winId, m_identifier);
        if (!m_created) {
            return;
        }
        m_dirty = true;
    }

    const QRectF rect{mapRectToScene(boundingRect())};
    const qreal opacity{isVisible() ? std::clamp(effectiveOpacity(), 0.0, 1.0) : 0.0};
    const auto alpha{static_cast<quint8>(qRound(opacity * 255.0))};
    if (!m_dirty && rect == m_lastRect && alpha == m_lastAlpha) {
        return;
    }

    m_dirty = false;
    m_lastRect = rect;
    m_lastAlpha = alpha;
    macwindow::updateGlassView(
        m_winId,
        m_identifier,
        rect,
        m_cornerRadius,
        QColor::fromRgba(m_tint),
        alpha / 255.0,
        m_clear
    );
}

} // namespace rask
