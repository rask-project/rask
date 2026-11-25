#pragma once

#include <Rask/Platform/raskplatform_export.h>

#include <QObject>
#include <QtQmlIntegration/qqmlintegration.h>

namespace rask
{

// The user's light/dark choice, saved in QSettings and applied to the whole
// application (Qt::ColorScheme::Unknown follows the system). QSettings is
// the only copy of the choice.
class RASK_PLATFORM_EXPORT Appearance : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
    Q_PROPERTY(Qt::ColorScheme colorScheme READ colorScheme WRITE setColorScheme NOTIFY colorSchemeChanged)
    Q_PROPERTY(bool dark READ dark NOTIFY darkChanged)
public:
    explicit Appearance(QObject *parent = nullptr);

    [[nodiscard]] static Qt::ColorScheme colorScheme();
    void setColorScheme(Qt::ColorScheme colorScheme);
    [[nodiscard]] bool dark() const;

signals:
    void colorSchemeChanged();
    void darkChanged();
};

} // namespace rask
