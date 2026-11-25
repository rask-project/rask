#pragma once

#include <Rask/Platform/raskplatform_export.h>

#include <QColor>
#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

#include <memory>

namespace rask
{

namespace macsystemcolors
{
class Observer;
} // namespace macsystemcolors

// AppKit's semantic colors (NSColor), resolved for the application's current
// appearance and refreshed when it, the accent or the highlight color change.
class RASK_PLATFORM_EXPORT SystemColors : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(QColor label READ label NOTIFY changed)
    Q_PROPERTY(QColor secondaryLabel READ secondaryLabel NOTIFY changed)
    Q_PROPERTY(QColor tertiaryLabel READ tertiaryLabel NOTIFY changed)
    Q_PROPERTY(QColor text READ text NOTIFY changed)
    Q_PROPERTY(QColor selectedTextBackground READ selectedTextBackground NOTIFY changed)
    Q_PROPERTY(QColor unemphasizedSelectedTextBackground READ unemphasizedSelectedTextBackground NOTIFY changed)
    Q_PROPERTY(QColor textInsertionPoint READ textInsertionPoint NOTIFY changed)
    Q_PROPERTY(QColor controlAccent READ controlAccent NOTIFY changed)
public:
    // The resolved colors, in sRGB.
    struct Colors {
        QColor label;
        QColor secondaryLabel;
        QColor tertiaryLabel;
        QColor text;
        QColor selectedTextBackground;
        QColor unemphasizedSelectedTextBackground;
        QColor textInsertionPoint;
        QColor controlAccent;
    };

    explicit SystemColors(QObject *parent = nullptr);
    ~SystemColors() override;
    SystemColors(const SystemColors &) = delete;
    SystemColors &operator=(const SystemColors &) = delete;
    SystemColors(SystemColors &&) = delete;
    SystemColors &operator=(SystemColors &&) = delete;

    [[nodiscard]] QColor label() const;
    [[nodiscard]] QColor secondaryLabel() const;
    [[nodiscard]] QColor tertiaryLabel() const;
    [[nodiscard]] QColor text() const;
    [[nodiscard]] QColor selectedTextBackground() const;
    [[nodiscard]] QColor unemphasizedSelectedTextBackground() const;
    [[nodiscard]] QColor textInsertionPoint() const;
    [[nodiscard]] QColor controlAccent() const;

signals:
    void changed();

private:
    void refresh();

    std::unique_ptr<macsystemcolors::Observer> m_observer;
    Colors m_colors;
};

} // namespace rask
