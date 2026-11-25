#pragma once

#include <Rask/Window/raskwindow_export.h>

#include <QColor>
#include <QPointer>
#include <QQuickItem>
#include <QQuickWindow>
#include <QRectF>
#include <QString>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// A QML item backed by a native Liquid Glass view (NSGlassEffectView, macOS
// 26+). The native view lives behind the Qt content view and follows this
// item's scene geometry, effective visibility and effective opacity every
// frame, so QML content drawn over the item appears on top of real glass.
// The window should be a NativeWindow (transparent, content under the title
// bar). Where `supported` is false nothing native is created: show
// GlassSurface (the same look drawn in QML) instead.
class RASK_WINDOW_EXPORT GlassEffect : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(bool supported READ supported CONSTANT)
    Q_PROPERTY(qreal cornerRadius READ cornerRadius WRITE setCornerRadius NOTIFY cornerRadiusChanged)
    Q_PROPERTY(QColor tint READ tint WRITE setTint NOTIFY tintChanged)
    // Clear (more transparent) glass instead of the regular frosted style.
    Q_PROPERTY(bool clear READ clear WRITE setClear NOTIFY clearChanged)
public:
    explicit GlassEffect(QQuickItem *parent = nullptr);
    ~GlassEffect() override;
    Q_DISABLE_COPY_MOVE(GlassEffect)

    [[nodiscard]] static bool supported() noexcept;
    [[nodiscard]] qreal cornerRadius() const noexcept { return m_cornerRadius; }
    void setCornerRadius(qreal radius);
    [[nodiscard]] QColor tint() const { return QColor::fromRgba(m_tint); }
    void setTint(const QColor &tint);
    [[nodiscard]] bool clear() const noexcept { return m_clear; }
    void setClear(bool clear);

signals:
    void cornerRadiusChanged();
    void tintChanged();
    void clearChanged();

protected:
    void itemChange(ItemChange change, const ItemChangeData &value) override;

private:
    void attach(QQuickWindow *window);
    void detach();
    void sync();
    void markDirty();
    [[nodiscard]] qreal effectiveOpacity() const;

    QRectF m_lastRect;
    QString m_identifier;
    QPointer<QQuickWindow> m_window;
    QMetaObject::Connection m_frameConnection;
    WId m_winId{0};
    qreal m_cornerRadius{8.0};
    QRgb m_tint{0U};
    // Effective opacity last pushed to the native view, quantized to 8 bits.
    quint8 m_lastAlpha{0U};
    bool m_clear{false};
    bool m_created{false};
    bool m_dirty{true};
};

} // namespace rask
