#pragma once

#include "SystemColors.h"

#include <functional>

// The native side of SystemColors (AppKit, MacSystemColors.mm).
namespace rask::macsystemcolors
{

// The semantic colors, resolved for NSApp's effective appearance.
[[nodiscard]] SystemColors::Colors resolve();

// Calls `onChange` (on the main thread) when the system's accent or
// highlight color changes; stops when destroyed.
class Observer
{
public:
    explicit Observer(const std::function<void()> &onChange);
    ~Observer();
    Observer(const Observer &) = delete;
    Observer &operator=(const Observer &) = delete;
    Observer(Observer &&) = delete;
    Observer &operator=(Observer &&) = delete;

private:
    struct Token;
    std::unique_ptr<Token> m_token;
};

} // namespace rask::macsystemcolors
