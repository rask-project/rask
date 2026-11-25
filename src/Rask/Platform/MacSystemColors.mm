#include "SystemColors_p.h"

#import <AppKit/AppKit.h>

namespace rask::macsystemcolors
{

namespace
{

QColor toQColor(NSColor *color)
{
    NSColor *const rgb{[color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]]};
    if (rgb == nil) {
        return {};
    }
    return QColor::fromRgbF(
        static_cast<float>(rgb.redComponent),
        static_cast<float>(rgb.greenComponent),
        static_cast<float>(rgb.blueComponent),
        static_cast<float>(rgb.alphaComponent)
    );
}

} // namespace

SystemColors::Colors resolve()
{
    __block SystemColors::Colors colors;
    NSAppearance *const appearance{NSApp != nil ? NSApp.effectiveAppearance : NSAppearance.currentDrawingAppearance};
    [appearance performAsCurrentDrawingAppearance:^{
      colors.label = toQColor(NSColor.labelColor);
      colors.secondaryLabel = toQColor(NSColor.secondaryLabelColor);
      colors.tertiaryLabel = toQColor(NSColor.tertiaryLabelColor);
      colors.text = toQColor(NSColor.textColor);
      colors.selectedTextBackground = toQColor(NSColor.selectedTextBackgroundColor);
      colors.unemphasizedSelectedTextBackground = toQColor(NSColor.unemphasizedSelectedTextBackgroundColor);
      colors.textInsertionPoint = toQColor(NSColor.textInsertionPointColor);
      colors.controlAccent = toQColor(NSColor.controlAccentColor);
      colors.findHighlight = toQColor(NSColor.findHighlightColor);
    }];
    return colors;
}

struct Observer::Token {
    id observer{nil};
};

Observer::Observer(const std::function<void()> &onChange) : m_token{std::make_unique<Token>()}
{
    m_token->observer = [NSNotificationCenter.defaultCenter addObserverForName:NSSystemColorsDidChangeNotification
                                                                        object:nil
                                                                         queue:NSOperationQueue.mainQueue
                                                                    usingBlock:^(NSNotification *) {
                                                                      onChange();
                                                                    }];
}

Observer::~Observer()
{
    [NSNotificationCenter.defaultCenter removeObserver:m_token->observer];
}

} // namespace rask::macsystemcolors
