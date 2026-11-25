#include "SystemColors.h"

#include "SystemColors_p.h"

#include <QGuiApplication>
#include <QStyleHints>

namespace rask
{

SystemColors::SystemColors(QObject *parent)
    : QObject(parent)
    , m_observer{std::make_unique<macsystemcolors::Observer>([this] { refresh(); })}
    , m_colors{macsystemcolors::resolve()}
{
    connect(QGuiApplication::styleHints(), &QStyleHints::colorSchemeChanged, this, &SystemColors::refresh);
}

SystemColors::~SystemColors() = default;

void SystemColors::refresh()
{
    m_colors = macsystemcolors::resolve();
    emit changed();
}

QColor SystemColors::label() const
{
    return m_colors.label;
}

QColor SystemColors::secondaryLabel() const
{
    return m_colors.secondaryLabel;
}

QColor SystemColors::tertiaryLabel() const
{
    return m_colors.tertiaryLabel;
}

QColor SystemColors::text() const
{
    return m_colors.text;
}

QColor SystemColors::selectedTextBackground() const
{
    return m_colors.selectedTextBackground;
}

QColor SystemColors::unemphasizedSelectedTextBackground() const
{
    return m_colors.unemphasizedSelectedTextBackground;
}

QColor SystemColors::textInsertionPoint() const
{
    return m_colors.textInsertionPoint;
}

QColor SystemColors::controlAccent() const
{
    return m_colors.controlAccent;
}

QColor SystemColors::findHighlight() const
{
    return m_colors.findHighlight;
}

} // namespace rask
