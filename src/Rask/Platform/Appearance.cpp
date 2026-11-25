#include "Appearance.h"

#include <QGuiApplication>
#include <QSettings>
#include <QStyleHints>

#include <utility>

namespace rask
{

namespace
{
constexpr auto settingsKey{"appearance/colorScheme"};
} // namespace

Appearance::Appearance(QObject *parent) : QObject(parent)
{
    QGuiApplication::styleHints()->setColorScheme(colorScheme());
    connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged, this, &Appearance::darkChanged);
}

void Appearance::setColorScheme(Qt::ColorScheme colorScheme)
{
    if (Appearance::colorScheme() == colorScheme) {
        return;
    }
    QSettings().setValue(settingsKey, std::to_underlying(colorScheme));
    QGuiApplication::styleHints()->setColorScheme(colorScheme);
    emit colorSchemeChanged();
    emit darkChanged();
}

bool Appearance::dark() const
{
    // Not every platform honours the override, so an explicit choice wins.
    const Qt::ColorScheme chosen{colorScheme()};
    if (chosen != Qt::ColorScheme::Unknown) {
        return chosen == Qt::ColorScheme::Dark;
    }
    return QGuiApplication::styleHints()->colorScheme() == Qt::ColorScheme::Dark;
}

Qt::ColorScheme Appearance::colorScheme()
{
    const qint32 saved{QSettings().value(settingsKey).toInt()};
    if (saved == std::to_underlying(Qt::ColorScheme::Light)) {
        return Qt::ColorScheme::Light;
    }
    if (saved == std::to_underlying(Qt::ColorScheme::Dark)) {
        return Qt::ColorScheme::Dark;
    }
    return Qt::ColorScheme::Unknown;
}

} // namespace rask
